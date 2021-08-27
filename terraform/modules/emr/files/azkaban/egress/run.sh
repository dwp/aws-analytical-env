#!/usr/bin/env bash

source "${AZKABAN_JOB_UTILITY_HOME:-/opt/emr/azkaban}/egress/environment.sh"

egress::egress "${1:?Usage $(basename "$0") prefix}"