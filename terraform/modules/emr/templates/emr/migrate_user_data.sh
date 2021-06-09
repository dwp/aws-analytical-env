#!/bin/bash
###############
# Set Variables
###############

SPO_UNREDACTED_DB=$1

BASE_DIR=/opt/emr/repos/migrate_user_data

echo "Getting ADG S3 prefix............."
ADG_PUBLISH_BUCKET="s3://"$PUBLISH_BUCKET_ID
S3_PREFIX="common-model-inputs/user_tables_migration"
RAW_DIR=$ADG_PUBLISH_BUCKET/$ADG_S3_PREFIX

echo "Looking for input SQL files..."

if [ -f $BASE_DIR/*.sql ]
then
    echo "SQL Files Found - Continuing build."
else
    echo "SQL Files Missing - ERROR"
    exit 1
fi

##############
# Build Tables
##############

hive -f $BUILD_DIR/*.sql  -hivevar spo_unredacted_db=$SPO_UNREDACTED_DB -hivevar s3_prefix=$RAW_DIR

RETVAL=$?
if [ $RETVAL -ne 0 ]
then
    echo "Problem building table for $DATASET"
    exit 1
else
    echo "Tables successfully built"
fi
