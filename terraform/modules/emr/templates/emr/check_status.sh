#!/bin/bash
DATA_PRODUCT=$1
DATA_SOURCE=$2

  #Read correlation id
  LATEST_COR_ID=`cat ~/${DATA_SOURCE}_CORRELATION_ID.txt`

  #RUN_ID will not be set if the data product did not run
  RUN_ID=$(hive -e "USE audit; SELECT run_id from data_pipeline_metadata_hive WHERE dataproduct = '${DATA_PRODUCT}' AND correlation_id = '${LATEST_COR_ID}';")
  echo "RUN_ID is ${RUN_ID} "

  #Get run status
  RUN_STATUS=$(hive -e "USE audit; SELECT status FROM data_pipeline_metadata_hive WHERE dataproduct = '${DATA_PRODUCT}' AND correlation_id = '${LATEST_COR_ID}';")
  echo "RUN_STATUS is ${RUN_STATUS} "

  if [  -z ${RUN_ID} ]
  then
    echo "correlation_id is :"$LATEST_COR_ID
    echo "Assigning the new Run Id to 1 "
    RUN_ID=1
    echo "Calling update_dynamo.sh"
    /opt/emr/repos/status_check/update_dynamo.sh $LATEST_COR_ID "In-Progress" $DATA_PRODUCT $RUN_ID #Logging
  elif [ ${RUN_STATUS^^} == "FAILED" ]
  then
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
