#!/usr/bin/env bash

if [[ -n "$1" ]]; then
  DATASOURCE="$1"
else DATASOURCE="PDM"
fi

if [[ -n "$2" ]]; then
  TIMEOUT="$2"
else
  TIMEOUT=3600
fi

((RETRIES=$TIMEOUT/30))

count=0
query="SELECT 1 FROM audit.data_pipeline_metadata_hive WHERE dataproduct = '${DATASOURCE}' AND upper(status) = 'COMPLETED' AND dateproductrun = current_date();"

while [ $count -lt $RETRIES ]; do
  status=$(hive -S -e "${query}")
  if [[ $status -eq 1 ]]; then
    exit 0
  else
    let count++
    sleep 60
  fi
done

exit 1
