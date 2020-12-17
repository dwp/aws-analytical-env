import os
from aws_sync_caller import get_users_in_userpool, execute_statement, create_cognito_client

variables = {}


def lambda_handler(event, context):
    get_env_vars()
    create_cognito_client(variables['mgmt_account_role_arn'])

    cognito_user_dict = get_user_dict_from_cognito(variables['cognito_userpool_id'])
    rds_user_dict = get_user_dict_from_rds(variables)

    sync_values(cognito_user_dict, rds_user_dict, variables)


# Gets env vars passed in from terraform as strings and builds the variables global dict.
def get_env_vars():
    variables['database_cluster_arn'] = os.getenv('DATABASE_CLUSTER_ARN')
    variables['database_name'] = os.getenv('DATABASE_NAME')
    variables['secret_arn'] = os.getenv('SECRET_ARN')
    variables['cognito_userpool_id'] = os.getenv('COGNITO_USERPOOL_ID')
    variables['mgmt_account_role_arn'] = os.getenv('MGMT_ACCOUNT_ROLE_ARN')

    for var in variables:
        if var is None or var == {}:
            raise Exception(f'Variable: {var} has not been provided.')


# queries RDS for all user data and returns a dict mapping username to active and user_name_sub
def get_user_dict_from_rds(variables_dict):
    return_dict = {}
    sql = f'SELECT User.userName, User.active FROM User'

    response = execute_statement(
        sql,
        variables_dict['secret_arn'],
        variables_dict["database_name"],
        variables_dict["database_cluster_arn"]
    )
    for record in response['records']:
        user_name = ''.join(record[0].values())
        user_name_raw = user_name[0:-3]
        active = list(record[1].values())[0]
        if return_dict.get(user_name_raw) == None:
            return_dict[user_name[0:-3]] = {
                'active': active,
                'user_name_sub': user_name
            }
    return return_dict


# queries Cognito userpool for all user data, returns a dict mapping username to active and user_name_sub
def get_user_dict_from_cognito(user_pool_id):
    users = get_users_in_userpool(user_pool_id)

    return_dict = {}

    user_object = lambda user, username: {
        username: {
            'active': user.get('Enabled'),
            'user_name_sub': ''.join([username, get_attribute(user.get('Attributes'), 'sub')[0:3]]),
            'account_name': user.get('Username')
        }
    }

    for user in users:
        username = get_attribute(user.get('Attributes'), 'preferred_username') or user.get('Username')
        return_dict.update(user_object(user, username))
    return return_dict


def get_attribute(attributes, name):
    for attribute in attributes:
        if attribute.get('Name') == name:
            return attribute.get('Value')
    return None


# compares rds user dict to cognito user dict and updates rds with values from cognito
def sync_values(cognito_user_dict, rds_user_dict, variables_dict):
    users_from_cognito = list(cognito_user_dict.keys())
    users_from_rds = list(rds_user_dict.keys())
    missing_from_rds = [key for key in users_from_cognito if key not in users_from_rds]
    removed_from_cognito = [key for key in users_from_rds if key not in users_from_cognito]

    for user in removed_from_cognito:
        update_user_status(rds_user_dict[user].get('user_name_sub'), variables_dict, 0)

    for user in missing_from_rds:
        add_user_to_rds(cognito_user_dict[user], variables_dict, 1 if cognito_user_dict[user].get('active') else 0)

    for user in set(users_from_cognito).intersection(users_from_rds):
        if rds_user_dict[user].get('active') != cognito_user_dict[user].get('active'):
            update_user_status(cognito_user_dict[user].get('user_name_sub'), variables_dict,
                               1 if cognito_user_dict[user].get('active') else 0)


def add_user_to_rds(user_object, variables_dict, status):
    sql = f'INSERT INTO User (username, active, accountname) ' \
          f'VALUES ("{user_object.get("user_name_sub")}", {status}, "{user_object.get("account_name")}");'
    execute_statement(
        sql,
        variables_dict['secret_arn'],
        variables_dict["database_name"],
        variables_dict["database_cluster_arn"]
    )


def update_user_status(user_name, variables_dict, new_status):
    sql = f'UPDATE User SET active = {new_status} WHERE username = "{user_name}";'
    execute_statement(
        sql,
        variables_dict['secret_arn'],
        variables_dict["database_name"],
        variables_dict["database_cluster_arn"]
    )
