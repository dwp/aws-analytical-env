#!/bin/bash
DATA_PRODUCT=$1
DEPENDANT_DATA_PRODUCT=$2
DURATION=$3

if [ -z "${DURATION}" ]
  then 
    END_TIME=80 #Seconds    ##Polls for 5 Hours then exits with Failure
  else
    END_TIME=${DURATION}    ##Polls for variable duration then exits with Failure
fi

INTERVAL=40 #Seconds     ##Checks for file flag file every 5 Minutes

DATE=$(date '+%Y-%m-%d')

while ((${SECONDS} < ${END_TIME}))
do
  #Get the status of the latest pdm run
  DEPENDANT_DATA_PRODUCT_STATUS=$(hive -S -e "USE audit; SELECT Status FROM data_pipeline_metadata_hive dp INNER JOIN (
   SELECT MAX(to_date(dateproductrun)) AS run_date FROM data_pipeline_metadata_hive WHERE dataproduct = '${DEPENDANT_DATA_PRODUCT}') md
   ON to_date(dp.dateproductrun) = md.run_date
    WHERE dp.dataproduct = '${DEPENDANT_DATA_PRODUCT}';")
  if [[ ${DEPENDANT_DATA_PRODUCT_STATUS^^} == "COMPLETED" ]]
  then
   break
  else
    echo "$DEPENDANT_DATA_PRODUCT is running... Still waiting."
  fi
  sleep ${INTERVAL}
done

if [[ ${DEPENDANT_DATA_PRODUCT_STATUS^^} != "COMPLETED" ]]
then
 echo "PDM did not finish. Exiting as a Failure - Please check previous dependencies for errors."
 exit 1
fi

#Get the correlation_id of the latest PDM run
  LATEST_COR_ID=$(hive -S -e "USE audit; SELECT correlation_id FROM data_pipeline_metadata_hive dp INNER JOIN (
   SELECT MAX(to_date(dateproductrun)) AS run_date FROM data_pipeline_metadata_hive WHERE dataproduct = '${DEPENDANT_DATA_PRODUCT}') md
   ON to_date(dp.dateproductrun) = md.run_date
    WHERE dp.dataproduct = '${DEPENDANT_DATA_PRODUCT}' AND upper(dp.status) = 'COMPLETED';") 

  #RUN_ID will not be set if the data product did not run after PDM has completed
  RUN_ID=$(hive -S -e "USE audit; SELECT run_id from data_pipeline_metadata_hive WHERE dataproduct = '${DATA_PRODUCT}' AND upper(status) = 'COMPLETED' AND correlation_id = '${LATEST_COR_ID}';")

  #Check for FAILED run
  RUN_STATUS=$(hive -S -e "USE audit; SELECT status FROM data_pipeline_metadata_hive WHERE dataproduct = '${DATA_PRODUCT}' AND upper(status) = 'FAILED' AND correlation_id = '${LATEST_COR_ID}';")

  if [  -z ${RUN_ID} ]
  then
    echo "$DEPENDANT_DATA_PRODUCT has finished, Dependencies have finished - Proceeding with flow"
    echo "correlation_id is :"$LATEST_COR_ID
    RUN_ID=1
    echo "Run Id is: "$RUN_ID
    ./update_dynamo.sh $LATEST_COR_ID "In-Progress" $DATA_PRODUCT $RUN_ID #Logging
  elif [ ${RUN_STATUS^^} == "FAILED" ]
  then
    echo "PDM is not running ............... "
    echo "Re-Running $DATA_PRODUCT after FAILURE"
    echo "correlation_id is :"$LATEST_COR_ID
    RUN_ID=$(($RUN_ID+1)) #Increment run id for logging
    echo "Run Id is: "$RUN_ID
    ./update_dynamo.sh $LATEST_COR_ID "In-Progress" $DATA_PRODUCT $RUN_ID #Logging
  elif [ ${RUN_STATUS^^} == "IN-PROGRESS" ]
  then
  echo "$DATA_PRODUCT is running ............... "
  exit 0
fi
