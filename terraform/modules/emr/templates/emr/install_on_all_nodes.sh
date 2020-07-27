#!/usr/bin/env bash

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)

BUCKET="${emr_bucket_path}/"
SCRIPT="${script_path}"

aws ssm send-command \
    --targets "Key=tag:Name,Values=aws-analytical-env" \
    --document-name "AWS-RunShellScript" \
    --parameters "commands=s3 cp $BUCKET$SCRIPT /tmp/r_packages_install.sh"

sleep 15

aws ssm send-command \
    --targets "Key=tag:Name,Values=aws-analytical-env" \
    --document-name "AWS-RunShellScript" \
    --parameters "commands=bash /tmp/r_packages_installsh"


