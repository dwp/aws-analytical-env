#!/usr/bin/env bash

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

if [[ -n "$5" ]]; then
  SNAPSHOT_TYPE="$5"
  query="SELECT correlation_id FROM audit.data_pipeline_metadata_hive WHERE dataproduct = '${DATASOURCE}' AND upper(status) = 'COMPLETED' AND dateproductrun = '${EXPORT_DATE}' AND snapshot_type = '${SNAPSHOT_TYPE}';"
else query="SELECT correlation_id FROM audit.data_pipeline_metadata_hive WHERE dataproduct = '${DATASOURCE}' AND upper(status) = 'COMPLETED' AND dateproductrun = '${EXPORT_DATE}';"
fi

MESSAGE="Beginning polling of status table..."
echo $MESSAGE
log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"

while [ $count -lt $TIMEOUT -a $(date +%s) -lt $ENDTIME ]; do
  CORRELATION_ID=$(hive -S -e "${query}")
  if [ -z "$CORRELATION_ID" ]; then
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
    exit 0
  fi
done

if [[ "$CALLING_JOB" != "UNKNOWN" ]]; then
  notifications::notify_failure "$CALLING_JOB" "Polling" || true
fi

MESSAGE="Polling of status table did not find $DATASOURCE within the provided time period. Exiting process"
echo $MESSAGE
log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"

exit 1
