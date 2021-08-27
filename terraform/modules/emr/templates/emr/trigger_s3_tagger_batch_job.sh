#!/bin/bash

set -euo pipefail

# We expect the job name as a parameter
JOB_NAME="$1"
S3_PREFIX="$2"
JOB_QUEUE="$3"

if [[ -z "$JOB_QUEUE" ]]; then
    JOB_QUEUE="pt_object_tagger"
fi

AWS_DEFAULT_REGION="$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)"
export AWS_DEFAULT_REGION

# Proxy needed to talk to AWS batch endpoint
https_proxy="${full_proxy}"
export https_proxy

echo "Triggering tagger with JobName $JOB_NAME and s3 prefix $S3_PREFIX"
aws batch submit-job \
--job-queue "$JOB_QUEUE" \
--job-definition ${job_definition_name} \
--job-name "$JOB_NAME" \
--parameters \
"{\"data-s3-prefix\": \"$S3_PREFIX\", \"csv-location\": \"s3://${config_bucket}/component/rbac/data_classification.csv\"}"

exit 0
