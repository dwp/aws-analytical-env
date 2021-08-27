#!/usr/bin/env bash

# TODO: bring these 2 files into this location
source "${EMR_UTILITY_HOME:-/opt/emr}/azkaban_notifications.sh"
source "${EMR_UTILITY_HOME:-/opt/emr}/azkaban_metrics.sh"

for library in "${AZKABAN_JOB_UTILITY_HOME:-/opt/emr/azkaban}"/common/*.sh; do
  if [[ $(basename "$library") != environment.sh ]]; then
    source "$library"
  fi
done
