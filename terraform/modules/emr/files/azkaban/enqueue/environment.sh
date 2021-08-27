#!/usr/bin/env bash

source "${AZKABAN_JOB_UTILITY_HOME:-/opt/emr/azkaban}/common/environment.sh"

enqueue::enqueue() {
  local source_directory=${1:?Usage: ${FUNCNAME[0]} source-directory destination-prefix}
  local destination_prefix=${2:?Usage: ${FUNCNAME[0]} source-directory destination-prefix}
  aws s3 cp --recursive "$source_directory" "s3://$(aws::publish_bucket)/$destination_prefix"
}
