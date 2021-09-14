#!/usr/bin/env bash

source "${AZKABAN_JOB_UTILITY_HOME:-/opt/emr/azkaban}/common/environment.sh"

control::control() {

  local -r input_directory=${1:?Usage: ${FUNCNAME[0]} input-directory}

  find "$input_directory" -type f | while read -r input_file; do
    basename "$input_file"
  done
}

