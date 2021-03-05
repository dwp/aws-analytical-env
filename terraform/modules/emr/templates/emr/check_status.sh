#!/bin/bash
DATA_PRODUCT=$1
DEPENDANT_DATA_PRODUCT=$2
DURATION=$3
INTERVAL=$4

if [ -z "${DURATION}" ]
  then
    END_TIME=80 #Seconds    ##Polls for 5 Hours then exits with Failure
  else
    END_TIME=${DURATION}    ##Polls for variable duration then exits with Failure
fi

if [ -z "${INTERVAL}" ]
then
     INTERVAL=40 #Seconds     ##Checks for file flag file every 5 Minutes
fi

DATE=$(date '+%Y-%m-%d')

while ((${SECONDS} < ${END_TIME}))
do
  #Get the status of the latest pdm run

  MAX_DATE=$(hive -e "SELECT MAX(to_date(dateproductrun)) AS run_date FROM audit.data_pipeline_metadata_hive WHERE dataproduct = '${DEPENDANT_DATA_PRODUCT}';")
  DEPENDANT_DATA_PRODUCT_STATUS=$(hive -e "SELECT max(Status) FROM audit.data_pipeline_metadata_hive WHERE dataproduct = '${DEPENDANT_DATA_PRODUCT}' and to_date(dateproductrun) = '${MAX_DATE}';")

  echo $DEPENDANT_DATA_PRODUCT_STATUS
  echo $MAX_DATE

  if [[ ${DEPENDANT_DATA_PRODUCT_STATUS^^} == *"COMPLETED"* ]]
  then
   break
  elif [[ ${DEPENDANT_DATA_PRODUCT_STATUS^^} == "IN-PROGRESS" ]]
  then
       echo "$DEPENDANT_DATA_PRODUCT is running... Still waiting."

  elif [[ ${DEPENDANT_DATA_PRODUCT_STATUS^^} == "FAILED" ]]
  then
       echo "$DEPENDANT_DATA_PRODUCT is FAILED. Exiting as a Failure - Please check previous dependencies for errors."
       exit 1
  fi

  echo "Sleeping for ${INTERVAL} secs"

  sleep ${INTERVAL}
done

  echo "Getting the Latest Correlation ID for $DEPENDANT_DATA_PRODUCT"

#Get the correlation_id of the latest PDM run
  LATEST_COR_ID=$(hive -e "SELECT max(correlation_id) FROM audit.data_pipeline_metadata_hive
                              WHERE to_date(dateproductrun) = '${MAX_DATE}'
                              and dataproduct = '${DEPENDANT_DATA_PRODUCT}'
                              AND upper(status) = 'COMPLETED';")

  echo "LATEST_COR_ID is ${LATEST_COR_ID}"

  echo $LATEST_COR_ID > ~/${DATA_PRODUCT}_CORRELATION_ID.txt

  echo "Fetching the RUN_ID for ${DATA_PRODUCT} and ${LATEST_COR_ID}"
  #RUN_ID will not be set if the data product did not run after PDM has completed
  RUN_ID=$(hive -e "USE audit; SELECT run_id from data_pipeline_metadata_hive WHERE dataproduct = '${DATA_PRODUCT}' AND upper(status) = 'COMPLETED' AND correlation_id = '${LATEST_COR_ID}';")
  echo "RUN_ID is ${RUN_ID} "


  echo "Fetching the RUN_STATUS  for ${DATA_PRODUCT} and ${LATEST_COR_ID}"
  #Check for FAILED run
  RUN_STATUS=$(hive -e "USE audit; SELECT status FROM data_pipeline_metadata_hive WHERE dataproduct = '${DATA_PRODUCT}' AND correlation_id = '${LATEST_COR_ID}';")
  echo "RUN_STATUS is ${RUN_STATUS} "

  if [  -z ${RUN_ID} ]
  then
    echo "$DEPENDANT_DATA_PRODUCT has finished, Dependencies have finished - Proceeding with flow"
    echo "correlation_id is :"$LATEST_COR_ID
    echo "Assigning the new Run Id to 1 "
    RUN_ID=1
    echo "Calling update_dynamo.sh"
    /opt/emr/repos/status_check/update_dynamo.sh $LATEST_COR_ID "In-Progress" $DATA_PRODUCT $RUN_ID #Logging
  elif [ ${RUN_STATUS^^} == "FAILED" ]
  then
    echo "${DEPENDANT_DATA_PRODUCT} is not running ............... "
    echo "Re-Running ${DATA_PRODUCT} after FAILURE"
    echo "correlation_id is :"$LATEST_COR_ID
    echo "Incrementing the RUN_ID "
    RUN_ID=$(($RUN_ID+1)) #Increment run id for logging
    echo "New Run Id is: "$RUN_ID
    echo "Calling update_dynamo.sh"
    /opt/emr/repos/status_check/update_dynamo.sh $LATEST_COR_ID "In-Progress" $DATA_PRODUCT $RUN_ID #Logging
  elif [ ${RUN_STATUS^^} == "IN-PROGRESS" ]
  then
  echo "$DATA_PRODUCT is running .... Exiting the process"
  exit 1
  elif [ ${RUN_STATUS^^} == "COMPLETED" ]
  then
  echo "$DATA_PRODUCT is already completed .... Exiting the process"
  exit 1
fi
