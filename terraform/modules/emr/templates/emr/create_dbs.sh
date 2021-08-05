#!/bin/bash

#Create databases
(
    # Import the logging functions
    source /opt/emr/logging.sh

    PROCESS_ID=$PPID

    PROCESSED_BUCKET="${processed_bucket}/data"
    PUBLISHED_BUCKET="${published_bucket}/data"

    START_MESSAGE="Start_creating_databases"
    echo $START_MESSAGE
    log_message $START_MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "create_dbs.sh" "NOT_SET"

    #create UC_Lab databasess
    hive -e "CREATE DATABASE IF NOT EXISTS uc_lab_staging LOCATION '$PROCESSED_BUCKET/uc_lab_staging';"
    hive -e "CREATE DATABASE IF NOT EXISTS uc_lab LOCATION '$PUBLISHED_BUCKET/uc_lab';"
    hive -e "CREATE DATABASE IF NOT EXISTS uc_payment_timelines LOCATION  '$PUBLISHED_BUCKET/uc_payment_timelines';"
    hive -e "CREATE DATABASE IF NOT EXISTS uc_claimant_history LOCATION  '$PUBLISHED_BUCKET/uc_claimant_history';"

    END_MESSAGE="Finish_creating_databases"
    echo $END_MESSAGE
    log_message $END_MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "create_dbs.sh" "NOT_SET"

)  >> /var/log/batch/create_dbs.log 2>&1
