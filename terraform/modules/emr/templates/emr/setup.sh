#!/usr/bin/env bash

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

PUB_BUCKET_ID="${publish_bucket_id}"
CONFIG_BUCKET_ID="${config_bucket}"
COMPACTION_BUCKET_ID="${compaction_bucket_id}"
echo "export PUBLISH_BUCKET_ID=$${PUB_BUCKET_ID}" | sudo tee /etc/profile.d/buckets.sh
echo "export CONFIG_BUCKET_ID=$${CONFIG_BUCKET_ID}" | sudo tee -a /etc/profile.d/buckets.sh
echo "export COMPACTION_BUCKET_ID=$${COMPACTION_BUCKET_ID}" | sudo tee -a /etc/profile.d/buckets.sh
source /etc/profile.d/buckets.sh

sudo yum update -y amazon-ssm-agent
sudo yum install -y jq

sudo mkdir -p /var/log/batch
sudo chown hadoop:hadoop /var/log/batch

sudo mkdir -p /var/log/si
sudo chown -R hadoop:hadoop /var/log/si
sudo chmod -R 775 /var/log/si

aws s3 cp "${logging_shell}"     /opt/emr/logging.sh
aws s3 cp "${cloudwatch_shell}"  /opt/emr/cloudwatch.sh
aws s3 cp "${get_scripts_shell}" /home/hadoop/get_scripts.sh
aws s3 cp "${azkaban_notifications_shell}" /opt/emr/azkaban_notifications.sh
aws s3 cp "${azkaban_metrics_shell}" /opt/emr/azkaban_metrics.sh
aws s3 cp "${delete_azkaban_metrics_shell}" /opt/emr/delete_azkaban_metrics.sh
aws s3 cp "${sft_utility_shell}" /opt/emr/sft_utility.sh
aws s3 cp "${poll_status_table_shell}" /home/hadoop/poll_status_table.sh
aws s3 cp "${trigger_tagger_shell}" /opt/emr/trigger_s3_tagger_batch_job.sh
aws s3 cp "${parallel_shell}" /opt/emr/parallel.sh
aws s3 cp "${patch_log4j_emr_shell}" /opt/emr/patch-log4j-emr-6.2.1-v1.sh
aws s3 cp "${config_hcs_shell}" /opt/emr/config_hcs.sh

sudo mkdir -p /opt/emr/azkaban
sudo mkdir -p /opt/emr/azkaban/chunk
sudo mkdir -p /opt/emr/azkaban/metadata
sudo mkdir -p /opt/emr/azkaban/control
sudo mkdir -p /opt/emr/azkaban/enqueue
sudo mkdir -p /opt/emr/azkaban/egress
sudo mkdir -p /opt/emr/azkaban/common
sudo chown -R hadoop:hadoop /opt/emr/azkaban

aws s3 cp "${azkaban_chunk_environment_sh}" /opt/emr/azkaban/chunk
aws s3 cp "${azkaban_metadata_environment_sh}" /opt/emr/azkaban/metadata
aws s3 cp "${azkaban_control_environment_sh}" /opt/emr/azkaban/control
aws s3 cp "${azkaban_enqueue_environment_sh}" /opt/emr/azkaban/enqueue
aws s3 cp "${azkaban_egress_environment_sh}" /opt/emr/azkaban/egress
aws s3 cp "${azkaban_chunk_run_sh}" /opt/emr/azkaban/chunk
aws s3 cp "${azkaban_metadata_run_sh}" /opt/emr/azkaban/metadata
aws s3 cp "${azkaban_control_run_sh}" /opt/emr/azkaban/control
aws s3 cp "${azkaban_enqueue_run_sh}" /opt/emr/azkaban/enqueue
aws s3 cp "${azkaban_egress_run_sh}" /opt/emr/azkaban/egress
aws s3 cp "${azkaban_common_aws_sh}" /opt/emr/azkaban/common
aws s3 cp "${azkaban_common_console_sh}" /opt/emr/azkaban/common
aws s3 cp "${azkaban_common_fs_sh}" /opt/emr/azkaban/common
aws s3 cp "${azkaban_common_environment_sh}" /opt/emr/azkaban/common
sudo chmod -R +x /opt/emr/azkaban
sudo chown -R hadoop:hadoop /opt/emr/azkaban

chmod u+x /opt/emr/config_hcs.sh
chmod u+x /opt/emr/cloudwatch.sh
chmod u+x /opt/emr/logging.sh
chmod u+x /home/hadoop/get_scripts.sh
chmod 775 /home/hadoop/poll_status_table.sh
chmod 775 /opt/emr/trigger_s3_tagger_batch_job.sh
chmod +x /opt/emr/delete_azkaban_metrics.sh
aws s3 cp s3://${config_bucket}/workflow-manager/azkaban/step.sh /home/hadoop/step.sh
chmod u+x /home/hadoop/step.sh

sudo /opt/emr/cloudwatch.sh \
    "${cwa_metrics_collection_interval}" "${cwa_log_group_name}" "${aws_default_region}" \
    "${cwa_namespace}" "${cwa_si_namespace}" "${cwa_si_log_group_name}"

echo "Running config_hcs script"
sudo mkdir -p /var/log/hcs
sudo chown -R hadoop:hadoop
sudo chmod -R 775 /var/log/hcs
/opt/emr/config_hcs.sh "${hcs_environment}" "${http_proxy_host}" "${http_proxy_port}"


echo "Assuming Cognito Role. Output hidden"
set +x

CREDS=$(aws sts assume-role --role-arn "${cognito_role_arn}" --role-session-name EMR_Get_Users | jq .Credentials)
export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r .AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r .SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r .SessionToken)

# Fix for TooManyRequestsException error when calling the cognito-idp api
MAX_RETRY_COUNT=20
RETRY_COUNT=0
until [ "$RETRY_COUNT" -ge "$MAX_RETRY_COUNT" ]
do
  COGNITO_GROUPS=$(aws cognito-idp list-groups --user-pool-id "${user_pool_id}" | jq '.Groups' | jq -r '.[].GroupName')
  if [ -z "$COGNITO_GROUPS" ]; then 
    RETRY_COUNT=$((RETRY_COUNT+1))
    echo "Cognito api call failed while getting groups, re-trying ($RETRY_COUNT/$MAX_RETRY_COUNT)..."
    sleep "$(( $RANDOM % 5 )).$(( $RANDOM % 1000 ))"s
  else
    echo "Cognito groups fetched successfully."
    break
  fi
done

sudo mkdir -p /opt/dataworks
sudo touch /opt/dataworks/users
sudo touch /opt/dataworks/groups

for GROUP in $${COGNITO_GROUPS[@]}; do
  echo "Creating group $GROUP"

  echo "Creating group level user for '$GROUP'"
  if id -u "$GROUP"; then
    echo "User already exists"
  else
    echo "Creating user '$GROUP'"
    if sudo useradd -m "$GROUP"; then
      echo "$GROUP" | sudo tee -a /opt/dataworks/users
      echo "$GROUP" | sudo tee -a /opt/dataworks/groups
    else
      echo "Cannot create user '$GROUP'"
      continue
    fi
  fi

  echo "Adding user '$GROUP' to group '$GROUP'"
  sudo usermod -aG hadoop "$GROUP"

  echo "Adding user '$GROUP' to group at.allow"
  sudo tee -a /etc/at.allow <<< "$GROUP"

  echo "Adding users for group $GROUP"

  # Fix for TooManyRequestsException error when calling the cognito-idp api
  RETRY_COUNT=0
  until [ "$RETRY_COUNT" -ge "$MAX_RETRY_COUNT" ]
  do
    USERS=$(aws cognito-idp list-users-in-group --user-pool-id "${user_pool_id}" --group-name "$GROUP" | jq '.Users[]' | jq -r '(.Attributes[] | if .Name =="preferred_username" then .Value else empty end) // .Username')
    if [ -z "$USERS" ]; then 
      RETRY_COUNT=$((RETRY_COUNT+1))
      echo "Cognito api call failed while getting groups, re-trying ($RETRY_COUNT/$MAX_RETRY_COUNT)..."
      sleep "$(( $RANDOM % 5 )).$(( $RANDOM % 1000 ))"s
    else
      echo "Cognito groups fetched successfully."
      break
    fi
  done

  # Fix for TooManyRequestsException error when calling the cognito-idp api
  RETRY_COUNT=0
  until [ "$RETRY_COUNT" -ge "$MAX_RETRY_COUNT" ]
  do
    USERDIR=$(aws cognito-idp list-users --user-pool-id "${user_pool_id}")
    if [ -z "$USERDIR" ]; then 
      RETRY_COUNT=$((RETRY_COUNT+1))
      echo "Cognito api call failed while getting groups, re-trying ($RETRY_COUNT/$MAX_RETRY_COUNT)..."
      sleep "$(( $RANDOM % 5 )).$(( $RANDOM % 1000 ))"s
    else
      echo "Cognito groups fetched successfully."
      break
    fi
  done

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

    echo "Adding user '$USERNAME' to at.allow"
    sudo tee -a /etc/at.allow <<< "$USERNAME"
  done
done

echo Adding hadoop user to at.allow
sudo tee -a /etc/at.allow <<< hadoop
