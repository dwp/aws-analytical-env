#!/usr/bin/env bash

# Import logging
source /opt/emr/logging.sh

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

MESSAGE="TIMEOUT set to: \"$TIMEOUT\""
echo $MESSAGE
log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"

count=0
query="SELECT 1 FROM audit.data_pipeline_metadata_hive WHERE dataproduct = '${DATASOURCE}' AND upper(status) = 'COMPLETED' AND dateproductrun = current_date();"

MESSAGE="Beginning polling of status table..."
echo $MESSAGE
log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"

while [ $count -lt $TIMEOUT ]; do
  status=$(hive -S -e "${query}")
  if [[ $status -eq 1 ]]; then
    MESSAGE="Polling of status table found that $DATASOURCE is now available!"
    echo $MESSAGE
    log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"

    exit 0
  else
    let count++
    sleep 60
    MESSAGE="$count attempts of $TIMEOUT so far. Retrying..."
    echo $MESSAGE
    log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"

  fi
done

MESSAGE="Polling of status table did not find $DATASOURCE within the provided time period. Exiting process"
echo $MESSAGE
log_message $MESSAGE "INFO" "NOT_SET" $PROCESS_ID "batch_emr" "poll_status_table.sh" "NOT_SET"

exit 1
