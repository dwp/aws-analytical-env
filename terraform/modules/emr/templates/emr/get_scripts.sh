#!/bin/bash

set -euo pipefail

SOURCE_LOCATION=$1
DESTINATION_LOCATION=$2

BUCKET="${config_bucket}"
SOURCE_PATH=$BUCKET/$SOURCE_LOCATION

(
    # Import the logging functions
    source /opt/emr/logging.sh
    
    START_MESSAGE="Start Downloading files from $SOURCE_LOCATION to $DESTINATION_LOCATION"
    log_message $START_MESSAGE "INFO" "NOT_SET" "$${PID}" "batch_emr" "get_scripts.sh" "NOT_SET"

    aws s3 cp $SOURCE_PATH $DESTINATION_LOCATION --recursive
    
    END_MESSAGE="Finish Downloading files from $SOURCE_LOCATION to $DESTINATION_LOCATION"
    log_message $END_MESSAGE "INFO" "NOT_SET" "$${PID}" "batch_emr" "get_scripts.sh" "NOT_SET"

)  >> /var/log/get_scripts.log 2>&1









