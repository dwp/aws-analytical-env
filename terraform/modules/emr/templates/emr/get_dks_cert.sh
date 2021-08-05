#!/usr/bin/env bash
# install_acm_cert_helper.sh
# https://github.com/dwp/acm-pca-cert-generator verison 0.11.0

set -e
set -u
set -x
set -o pipefail

echo -n "Running as: "
whoami

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)
FULL_PROXY="${full_proxy}"
FULL_NO_PROXY="${full_no_proxy}"
export http_proxy="$FULL_PROXY"
export HTTP_PROXY="$FULL_PROXY"
export https_proxy="$FULL_PROXY"
export HTTPS_PROXY="$FULL_PROXY"
export no_proxy="$FULL_NO_PROXY"
export NO_PROXY="$FULL_NO_PROXY"

## get dks cert
export TRUSTSTORE_PASSWORD=$(uuidgen -r)
export KEYSTORE_PASSWORD=$(uuidgen -r)
export PRIVATE_KEY_PASSWORD=$(uuidgen -r)
export ACM_KEY_PASSWORD=$(uuidgen -r)

sudo mkdir -p /opt/emr
sudo chown hadoop:hadoop /opt/emr
touch /opt/emr/dks.properties
cat >> /opt/emr/dks.properties <<EOF
identity.store.alias=${private_key_alias}
identity.key.password=$PRIVATE_KEY_PASSWORD
spark.ssl.fs.enabled=true
spark.ssl.keyPassword=$KEYSTORE_PASSWORD
identity.keystore=/opt/emr/keystore.jks
identity.store.password=$KEYSTORE_PASSWORD
trust.keystore=/opt/emr/truststore.jks
trust.store.password=$TRUSTSTORE_PASSWORD
data.key.service.url=${dks_endpoint}
EOF

acm-cert-retriever \
--acm-cert-arn "${acm_cert_arn}" \
--acm-key-passphrase "$ACM_KEY_PASSWORD" \
--keystore-path "/opt/emr/keystore.jks" \
--keystore-password "$KEYSTORE_PASSWORD" \
--private-key-alias "${private_key_alias}" \
--private-key-password "$PRIVATE_KEY_PASSWORD" \
--truststore-path "/opt/emr/truststore.jks" \
--truststore-password "$TRUSTSTORE_PASSWORD" \
--truststore-aliases "${truststore_aliases}" \
--truststore-certs "${truststore_certs}" \
--jks-only true

UUID=$(dbus-uuidgen | cut -c 1-8)
TOKEN=$(curl -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" "http://169.254.169.254/latest/api/token")
export INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token:$TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
export INSTANCE_ROLE=$(jq .instanceRole /mnt/var/lib/info/extraInstanceData.json)
export CLUSTER_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" | jq -r '.Tags[].Value')
export HOSTNAME=$CLUSTER_NAME-$${INSTANCE_ROLE//\"}-$UUID

sudo hostnamectl set-hostname $HOSTNAME
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=$HOSTNAME
