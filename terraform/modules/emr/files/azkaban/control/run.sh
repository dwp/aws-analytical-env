#!/usr/bin/env bash

source "${AZKABAN_JOB_UTILITY_HOME:-/opt/emr/azkaban}/control/environment.sh"

control::control "${1:?Usage $(basename "$0") input-directory output-file}" \
  > "${2:?Usage $(basename "$0") input-directory output-file}"