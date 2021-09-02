#!/usr/bin/env bash

source "${AZKABAN_JOB_UTILITY_HOME:-/opt/emr/azkaban}/common/environment.sh"

egress::egress() {
  local prefix=${1:?Usage: ${FUNCNAME[0]} prefix}
  aws s3api put-object --bucket "$(aws::publish_bucket)" --key "$prefix/pipeline_success.flag"
}
