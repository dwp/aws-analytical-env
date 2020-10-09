#!/usr/bin/env bash

set -e
set -u
set -x
set -o pipefail

echo -n "Running as: "
whoami

export AWS_DEFAULT_REGION=${aws_default_region}

FULL_PROXY="${full_proxy}"
FULL_NO_PROXY="${full_no_proxy}"
export http_proxy="$FULL_PROXY"
export HTTP_PROXY="$FULL_PROXY"
export https_proxy="$FULL_PROXY"
export HTTPS_PROXY="$FULL_PROXY"
export no_proxy="$FULL_NO_PROXY"
export NO_PROXY="$FULL_NO_PROXY"

sudo yum update -y amazon-ssm-agent
sudo yum install -y jq

echo "Assuming Cognito Role. Output hidden"
set +x

CREDS=$(aws sts assume-role --role-arn "${cognito_role_arn}" --role-session-name EMR_Get_Users | jq .Credentials)
export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r .AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r .SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r .SessionToken)

set -x

COGNITO_GROUPS=$(aws cognito-idp list-groups --user-pool-id "${user_pool_id}" | jq '.Groups' | jq -r '.[].GroupName')

sudo mkdir -p /opt/dataworks
sudo touch /opt/dataworks/users

for GROUP in $${COGNITO_GROUPS[@]}; do
  echo "Creating group $GROUP"

  echo "Creating group level user for '$GROUP'"
  if id -u "$GROUP"; then
    echo "User already exists"
  else
    echo "Creating user '$GROUP'"
    if sudo useradd -m "$GROUP"; then
      echo "$GROUP" | sudo tee -a /opt/dataworks/users
    else
      echo "Cannot create user '$GROUP'"
      continue
    fi
  fi

  echo "Adding user '$GROUP' to group '$GROUP'"
  sudo usermod -aG hadoop "$GROUP"

  echo "Adding users for group $GROUP"
  USERS=$(aws cognito-idp list-users-in-group --user-pool-id "${user_pool_id}" --group-name "$GROUP" | jq '.Users[]' | jq -r '(.Attributes[] | if .Name =="preferred_username" then .Value else empty end) // .Username')

  USERDIR=$(aws cognito-idp list-users --user-pool-id "${user_pool_id}")

  for USER in $${USERS[@]}; do

    echo "Constructing username for $USER"
    # Append sub to username
    USERNAME=$(echo $USERDIR \
            | jq ".Users[] as \$u | if ( (\$u.Attributes[] | if .Name ==\"preferred_username\" then .Value else empty end) // \$u.Username) == \"$USER\" then \$u else empty end " \
            | jq -r ".Attributes[] | if .Name == \"sub\" then \"$USER\" + (.Value | match(\"...\").string) else empty end")

    echo "Attempting to create $USERNAME if they don't exist"
    if id -u "$USERNAME"; then
      echo "User already exists"
    else
      echo "Creating user '$USERNAME'"
      if sudo useradd -m "$USERNAME"; then
        echo "$USERNAME" | sudo tee -a /opt/dataworks/users
      else
        echo "Cannot create user '$USERNAME'"
        continue
      fi
    fi

    echo "Adding user '$USERNAME' to group '$GROUP'"
    sudo usermod -aG hadoop "$USERNAME"
    sudo usermod -aG "$GROUP" "$USERNAME"

  done
done

%%%%% Fix up Hive
echo "export AWS_STS_REGIONAL_ENDPOINTS=regional" | sudo tee -a /etc/hive/conf/hive_env.sh
chmod 444 /var/aws/emr/userData.json
