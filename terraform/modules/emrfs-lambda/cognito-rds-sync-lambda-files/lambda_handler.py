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
            raise AttributeError(f'Variable: {var} has not been provided.')


# queries RDS for all user data and returns a dict mapping username+sub to username, active and account_name
def get_user_dict_from_rds(variables_dict):
    return_dict = {}
    sql = f'SELECT User.accountName, User.userName, User.active FROM User'

    response = execute_statement(
        sql,
        variables_dict['secret_arn'],
        variables_dict["database_name"],
        variables_dict["database_cluster_arn"]
    )
    for record in response['records']:
        account_name = ''.join(record[0].values())
        user_name_sub = ''.join(record[1].values())
        user_name_raw = user_name_sub[0:-3]
        active = list(record[2].values())[0]
        if return_dict.get(user_name_sub) == None:
            return_dict[user_name_sub] = {
                'active': active,
                'username': user_name_raw,
                'account_name': account_name
            }
    return return_dict


# queries Cognito userpool for all user data, returns a dict mapping username+sub to username, active and account_name
def get_user_dict_from_cognito(user_pool_id):
    users = get_users_in_userpool(user_pool_id)
    return_dict = {}

    user_object = lambda user, username: {
        ''.join([username, get_attribute(user.get('Attributes'), 'sub')[0:3]]): {
            'active': user.get('Enabled'),
            'username': username,
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
    print(missing_from_rds)
    removed_from_cognito = [key for key in users_from_rds if key not in users_from_cognito]
    print(removed_from_cognito)

    for user in removed_from_cognito:
        update_user_status(user, variables_dict, 0)

    for user in missing_from_rds:
        add_user_to_rds(user, cognito_user_dict[user].get("account_name"), variables_dict, 1 if cognito_user_dict[user].get('active') else 0)

    for user in set(users_from_cognito).intersection(users_from_rds):
        if rds_user_dict[user].get('active') != cognito_user_dict[user].get('active'):
            update_user_status(user, variables_dict,
                               1 if cognito_user_dict[user].get('active') else 0)


def add_user_to_rds(user_name_sub, account_name, variables_dict, status):
    sql = f'INSERT INTO User (userName, active, accountName) ' \
          f'VALUES ("{user_name_sub}", {status}, "{account_name}");'
    print(sql)
    execute_statement(
        sql,
        variables_dict['secret_arn'],
        variables_dict["database_name"],
        variables_dict["database_cluster_arn"]
    )


def update_user_status(user_name, variables_dict, new_status):
    sql = f'UPDATE User SET active = {new_status} WHERE userName = "{user_name}";'
    print(sql)
    execute_statement(
        sql,
        variables_dict['secret_arn'],
        variables_dict["database_name"],
        variables_dict["database_cluster_arn"]
    )
