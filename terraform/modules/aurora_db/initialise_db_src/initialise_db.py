import os
import logging
import boto3

RDS_CREDENTIALS_SECRET_NAME = os.environ["RDS_CREDENTIALS_SECRET_NAME"]
RDS_DATABASE_NAME = os.environ["RDS_DATABASE_NAME"]
RDS_CLUSTER_ARN = os.environ["RDS_CLUSTER_ARN"]

rds_client = boto3.client('rds-data')
s3_client = boto3.client('s3')

# Initialise logging
logger = logging.getLogger(__name__)
log_level = os.environ["LOG_LEVEL"] if "LOG_LEVEL" in os.environ else "INFO"
logger.setLevel(logging.getLevelName(log_level.upper()))
logger.info("Logging at {} level".format(log_level.upper()))

def execute_statement(sql):
    response = rds_client.execute_statement(
        secretArn=RDS_CREDENTIALS_SECRET_NAME,
        database=RDS_DATABASE_NAME,
        resourceArn=RDS_CLUSTER_ARN,
        sql=sql
    )
    return response


def get_init_sql_from_s3():
    bucket = os.environ["INIT_SQL_S3_BUCKET"]
    key = os.environ["INIT_SQL_S3_KEY"]
    logger.debug(f"Getting SQL config from S3. Bucket={bucket} Key={key}")
    response = s3_client.get_object(Bucket=bucket, Key=key)
    return response["Body"].read().decode("utf8")


def handler(event: dict, context):
    logger.info(f"Using credentials from Secrets Manager secret with name {RDS_CREDENTIALS_SECRET_NAME}")

    if "drop_existing" in event and event["drop_existing"] == "true":
        logger.warning(f"Dropping all existing tables from database {RDS_DATABASE_NAME}")
        execute_statement(f"DROP DATABASE {RDS_DATABASE_NAME}; CREATE DATABASE {RDS_DATABASE_NAME};")

    logger.info(f"Initialising database with arn {RDS_CLUSTER_ARN}")

    init_sql = get_init_sql_from_s3()
    logger.debug(f"SQL Statements:\n{init_sql}")

    return execute_statement(init_sql)
