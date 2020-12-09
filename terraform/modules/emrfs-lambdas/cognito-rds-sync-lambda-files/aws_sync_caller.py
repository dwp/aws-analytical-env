from collections import ChainMap
import boto3

rds_data_client = boto3.client('rds-data')
cognito_client = boto3.client('cognito-idp')


# returns list of all users and their 'sub' attribute from userpool - includes enabled status
def get_users_in_userpool(user_pool_id):
    return cognito_client.list_users(
        UserPoolId=user_pool_id,
        AttributesToGet=[
            'sub',
        ],
    ).get('Users')


# returns list of all groups assigned to a user
def get_groups_for_user(user_name_no_sub, user_pool_id):
    return cognito_client.admin_list_groups_for_user(
        Username=user_name_no_sub,
        UserPoolId=user_pool_id,
    ).get('Groups')


# connects to RDS instance and executes the SQL statement passed in
def execute_statement(sql, db_credentials_secrets_store_arn, database_name, db_cluster_arn):
    response = rds_data_client.execute_sql(
        secretArn=db_credentials_secrets_store_arn,
        database=database_name,
        resourceArn=db_cluster_arn,
        sql=sql
    )
    return response






