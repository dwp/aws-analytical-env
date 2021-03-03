#!/bin/bash
DATA_PRODUCT=$1
DURATION=$2

if [ -z "${DURATION}" ]
  then 
    END_TIME=18000 #Seconds    ##Polls for 5 Hours then exits with Failure
  else
    END_TIME=${DURATION}    ##Polls for variable duration then exits with Failure
fi

INTERVAL=300 #Seconds     ##Checks for file flag file every 5 Minutes

DATE=$(date '+%Y-%m-%d')

while ((${SECONDS} < ${END_TIME}))
do
  latest_cor_id=$(hive -S -e "USE audit; SELECT correlation_id FROM data_pipeline_metadata_hive dp INNER JOIN (
   SELECT MAX(to_date(dateproductrun)) AS run_date FROM data_pipeline_metadata_hive WHERE dataproduct = 'PDM' AND status = 'COMPLETED') md
   ON to_date(dp.dateproductrun) = md.run_date
    WHERE dp.dataproduct = 'PDM' AND dp.status = 'COMPLETED' LIMIT 1;") 

  pt_2_check=$(hive -S -e "USE audit; SELECT dataproduct from data_pipeline_metadata_hive WHERE dataproduct = '${DATA_PRODUCT}' AND status = 'COMPLETED' AND correlation_id = '${latest_cor_id}';")
  
  if [ -z ${pt_2_check} ]
  then
    echo "PDM has finished, Dependencies have finished - Proceeding with flow"
    echo "correlation_id is :"$latest_cor_id
    exit 0
  else
    echo "PDM is running... Still waiting."
  fi
  sleep ${INTERVAL}
done

echo "PDM did not finish. Exiting as a Failure - Please check previous dependencies for errors."
exit 1
