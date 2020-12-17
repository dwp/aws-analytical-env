import os
import logging
import boto3

RDS_CREDENTIALS_SECRET_ARN = os.environ["RDS_CREDENTIALS_SECRET_ARN"]
RDS_DATABASE_NAME = os.environ["RDS_DATABASE_NAME"]
RDS_CLUSTER_ARN = os.environ["RDS_CLUSTER_ARN"]

rds_client = boto3.client('rds-data')
s3_client = boto3.client('s3')

# Initialise logging
logger = logging.getLogger(__name__)
log_level = os.environ["LOG_LEVEL"] if "LOG_LEVEL" in os.environ else "INFO"
logger.setLevel(logging.getLevelName(log_level.upper()))
logger.info("Logging at {} level".format(log_level.upper()))


def execute_statement(sql, database_name=None):
    args = {
        "secretArn": RDS_CREDENTIALS_SECRET_ARN,
        "resourceArn": RDS_CLUSTER_ARN,
        "sql": sql
    }
    if database_name is not None:
        args["database"] = database_name

    response = rds_client.execute_statement(**args)
    return response


def get_init_sql_from_s3():
    bucket = os.environ["INIT_SQL_S3_BUCKET"]
    key = os.environ["INIT_SQL_S3_KEY"]
    logger.debug(f"Getting SQL config from S3. Bucket={bucket} Key={key}")
    response = s3_client.get_object(Bucket=bucket, Key=key)
    return response["Body"].read().decode("utf8")


def split_statements(sql: str) -> list:
    clean_sql = " ".join(sql.strip().split())
    return [statement + ";" for statement in clean_sql.split(";") if statement != '']


def get_database_tables_schema(database_name):
    records = execute_statement(f"""
    SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, COLUMN_TYPE
    FROM information_schema.columns
    WHERE table_schema = "{database_name}" ORDER BY TABLE_NAME, ORDINAL_POSITION;""")["records"]

    return [{
        "table_name": record[0]["stringValue"],
        "column_name": record[1]["stringValue"],
        "data_type": record[2]["stringValue"],
        "column_type": record[3]["stringValue"],
    } for record in records]


def handler(event: dict, context):
    logger.info(f"Using credentials from Secrets Manager secret with arn {RDS_CREDENTIALS_SECRET_ARN}")

    if "drop_existing" in event and event["drop_existing"] == "true":
        logger.warning(f"Dropping all existing tables from database {RDS_DATABASE_NAME}")
        execute_statement(f"DROP DATABASE {RDS_DATABASE_NAME};")
        execute_statement(f"CREATE DATABASE {RDS_DATABASE_NAME};")

    logger.info(f"Initialising database with arn {RDS_CLUSTER_ARN}")

    init_sql = get_init_sql_from_s3()
    statements = split_statements(init_sql)
    logger.debug(f"SQL Statements:\n{statements}")

    for statement in statements:
        execute_statement(statement, RDS_DATABASE_NAME)

    logger.info("Successfully initialised database")
    return {"database_schema": get_database_tables_schema(RDS_DATABASE_NAME)}
