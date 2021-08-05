#!/bin/bash

CORRELATION_ID=$1
STATUS=$2
DATA_PRODUCT=$3
RUN_ID=$4

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)


if [  -z ${RUN_ID} ]
then
    response=`aws dynamodb get-item --table-name data_pipeline_metadata --key '{"Correlation_Id": {"S": "'$CORRELATION_ID'"}, "DataProduct": {"S": "'$DATA_PRODUCT'"}}'`
    RUN_ID=`echo $response | jq -r .'Item.Run_Id.N'`
fi

if [  -z ${CORRELATION_ID} ]
then
    CORRELATION_ID=`cat ~/${DATA_PRODUCT}_CORRELATION_ID.txt`
fi

CLUSTER_ID=`cat /mnt/var/lib/info/job-flow.json | jq '.jobFlowId'`
CLUSTER_ID=${CLUSTER_ID//\"}

DATE=$(date '+%Y-%m-%d')

$(which aws) dynamodb update-item \
    --table-name data_pipeline_metadata \
    --key "{\"Correlation_Id\":{\"S\":\"$CORRELATION_ID\"},\"DataProduct\":{\"S\":\"$DATA_PRODUCT\"}}" \
    --update-expression "SET #a = :x, #d = :w, Run_Id = :z, Cluster_Id = :u"  \
    --expression-attribute-value "{\":w\": {\"S\":\"$DATE\"}, \":x\": {\"S\":\"$STATUS\"}, \":u\": {\"S\":\"$CLUSTER_ID\"},\":z\": {\"N\":\"$RUN_ID\"}}" \
    --expression-attribute-names '{"#d": "Date", "#a": "Status"}' \
    --return-values ALL_NEW
