import boto3

rds_data_client = boto3.client('rds-data')
sts_connection = boto3.client('sts')

# assumes mgmt role to set up cognito client associated with mgmt account
def create_cognito_client(mgmt_account_role_arn):
    mgmt_account = sts_connection.assume_role(
        RoleArn=mgmt_account_role_arn,
        RoleSessionName="mgmt_cognito_rds_sync_lambda"
    )
    # create cognito client using the assumed role credentials in mgmt acc
    global cognito_client
    cognito_client = boto3.client(
        'cognito-idp',
        aws_access_key_id=mgmt_account['Credentials']['AccessKeyId'],
        aws_secret_access_key=mgmt_account['Credentials']['SecretAccessKey'],
        aws_session_token=mgmt_account['Credentials']['SessionToken']
    )


# returns list of all users and their 'sub' attribute from userpool - includes enabled status
def get_users_in_userpool(user_pool_id):
    
    response = cognito_client.list_users(
        UserPoolId=user_pool_id,
    )
    users = response.get('Users')

    while response.get('PaginationToken') is not None:
        response = cognito_client.list_users(
            UserPoolId      = user_pool_id,
            PaginationToken = response.get('PaginationToken')
        )
        users.extend(response.get('Users'))

    return users

# connects to RDS instance and executes the SQL statement passed in
def execute_statement(sql, db_credentials_secrets_store_arn, database_name, db_cluster_arn):
    response = rds_data_client.execute_statement(
        secretArn=db_credentials_secrets_store_arn,
        database=database_name,
        resourceArn=db_cluster_arn,
        sql=sql
    )
    return response






