#!/usr/bin/env bash

set -e

# Import logging
source /opt/emr/logging.sh
source /opt/emr/azkaban_notifications.sh || true

PROCESS_ID=$PPID

if [[ -n "$1" ]]; then
  DATASOURCE="$1"
else DATASOURCE="PDM"
fi

MESSAGE="DATASOURCE set to: \"$DATASOURCE\""
echo $MESSAGE
log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"


if [[ -n "$2" ]]; then
  TIMEOUT="$2"
else
  TIMEOUT=60
fi

let ENDTIME="$(date +%s) + 60 * $TIMEOUT"

MESSAGE="TIMEOUT set to: \"$TIMEOUT\""
echo $MESSAGE
log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"

if [[ -n "$3" ]]; then
  EXPORT_DATE="$3"
else EXPORT_DATE=$(date +"%Y-%m-%d")
fi

MESSAGE="EXPORT_DATE set to: \"$EXPORT_DATE\""
echo $MESSAGE
log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"

CALLING_JOB=${4:-UNKNOWN}
MESSAGE="CALLING_JOB set to: \"$CALLING_JOB\""
echo $MESSAGE
log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"

count=0
query="SELECT correlation_id FROM audit.data_pipeline_metadata_hive WHERE dataproduct = '${DATASOURCE}' AND upper(status) = 'COMPLETED' AND dateproductrun = '${EXPORT_DATE}';"

MESSAGE="Beginning polling of status table..."
echo $MESSAGE
log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"

notifications::notify_started "$CALLING_JOB" "Polling" || true

while [ $count -lt $TIMEOUT -a $(date +%s) -lt $ENDTIME ]; do
  CORRELATION_ID=$(hive -S -e "${query}")
  if [ -z $CORRELATION_ID ]; then
    let count++ || true
    sleep 60
    MESSAGE="$count attempts of $TIMEOUT so far. Retrying..."
    echo $MESSAGE
    log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"

  else
    MESSAGE="Polling of status table found that $DATASOURCE is now available!"
    echo $CORRELATION_ID > ~/${DATASOURCE}_CORRELATION_ID.txt
    echo $MESSAGE
    log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"
    notifications::notify_success "$CALLING_JOB" "Polling" || true
    exit 0
  fi
done

notifications::notify_failure "$CALLING_JOB" "Polling" || true

MESSAGE="Polling of status table did not find $DATASOURCE within the provided time period. Exiting process"
echo $MESSAGE
log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"

exit 1
