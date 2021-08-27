#!/usr/bin/env bash

source "${AZKABAN_JOB_UTILITY_HOME:-/opt/emr/azkaban}/enqueue/environment.sh"

enqueue::enqueue "${1:?Usage $(basename "$0") source-directory target-prefix}" \
                 "${2:?Usage $(basename "$0") source-directory target-prefix}"
