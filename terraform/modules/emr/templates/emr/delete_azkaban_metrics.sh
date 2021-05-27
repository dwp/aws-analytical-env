#!/bin/bash

source /opt/emr/azkaban_metrics.sh

JOB=${1:?Usage: $0 job step}
STEP=${2:?Usage: $0 job step}

metrics::delete "$JOB" "$STEP"

