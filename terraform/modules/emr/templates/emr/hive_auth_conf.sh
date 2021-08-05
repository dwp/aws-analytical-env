#!/usr/bin/env bash
set -e
set -u
set -x
set -o pipefail

(

echo -n "Running as: "
whoami

sudo aws s3 cp ${hive_auth_provider_s3_uri} /usr/lib/hive/lib/dataworks-custom-auth-provider.jar

FULL_PROXY="${full_proxy}"
FULL_NO_PROXY="${full_no_proxy}"
export http_proxy="$FULL_PROXY"
export HTTP_PROXY="$FULL_PROXY"
export https_proxy="$FULL_PROXY"
export HTTPS_PROXY="$FULL_PROXY"
export no_proxy="$FULL_NO_PROXY"
export NO_PROXY="$FULL_NO_PROXY"

curl https://cognito-idp.${aws_region}.amazonaws.com/${user_pool_id}/.well-known/jwks.json > /tmp/cognito.jwks
sudo mv /tmp/cognito.jwks /opt/dataworks/cognito.jwks
sudo sed -i '/^\[Service\]/a Environment=COGNITO_KEYSTORE_URL=file:///opt/dataworks/cognito.jwks' /etc/systemd/system/hive-server2.service

sudo systemctl daemon-reload
sudo systemctl restart hive-server2

) >> /var/log/batch/hive_auth_conf.log 2>&1

