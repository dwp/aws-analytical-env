#!/bin/bash

set -euo pipefail

SOURCE_LOCATION=$1
DESTINATION_LOCATION=$2

BUCKET="${config_bucket}"
SOURCE_PATH=$BUCKET/$SOURCE_LOCATION

(
    # Import the logging functions
    source /opt/emr/logging.sh
    PROCESS_ID=$PPID
    START_MESSAGE="Start_Downloading_Files"
    log_message $START_MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "get_scripts.sh" "NOT_SET"

    aws s3 sync $SOURCE_PATH $DESTINATION_LOCATION --exact-timestamps
    
    END_MESSAGE="Finish_Downloading_Files"
    log_message $END_MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "get_scripts.sh" "NOT_SET"

)  >> /var/log/batch/get_scripts.log 2>&1

sudo find "$DESTINATION_LOCATION" -name "*.sh" -exec chmod g+x {} \;







