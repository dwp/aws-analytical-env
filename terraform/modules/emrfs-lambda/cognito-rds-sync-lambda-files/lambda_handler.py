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


# queries RDS for all user data and returns a dict mapping username to active, group_names and user_name_sub
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


# queries Cognito userpool for all user data and returns a dict mapping username to active, group_names and user_name_sub
def get_user_dict_from_cognito(user_pool_id):
    users = get_users_in_userpool(user_pool_id)

    return_dict = {}

    user_object = lambda user, username: {
        username: {
            'active': user.get('Enabled'),
            'user_name_sub':''.join([username, get_attribute(user.get('Attributes'), 'sub')[0:3]]),
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
    cognito_keys = list(cognito_user_dict.keys())
    rds_keys = list(rds_user_dict.keys())
    cognito_only = [key for key in cognito_keys if key not in rds_keys]
    rds_only = [key for key in rds_keys if key not in cognito_keys]
    all_keys = cognito_keys
    all_keys.extend(rds_only)
    inserts_added = False
    updates_added = False

    inserts='INSERT INTO User (username, active, accountname) VALUES '
    active_cases='UPDATE User SET active =(case '
    update_condition='WHERE username in ('
    for key in all_keys:
        if key in cognito_only:
            # sql to add user to user table
            inserts = f'{inserts}' \
                      f'("{cognito_user_dict[key].get("user_name_sub")}", ' \
                      f'{cognito_user_dict[key].get("active")}, ' \
                      f'"{cognito_user_dict[key].get("account_name")}"), '
            inserts_added = True

        elif key in rds_only:
            active_cases = f'{active_cases}when username = "{rds_user_dict[key].get("user_name_sub")}" then 0 '
            update_condition = f'{update_condition}"{rds_user_dict[key].get("user_name_sub")}", '
            updates_added = True

        elif key in cognito_keys \
                and key in rds_keys \
                and rds_user_dict[key].get('active') != cognito_user_dict[key].get('active'):
            # sql statement to update existing user status
            active_cases = f'{active_cases}' \
                           f'when username = "{cognito_user_dict[key].get("user_name_sub")}" ' \
                           f'then {1 if cognito_user_dict[key].get("active") else 0} '
            update_condition = f'{update_condition}"{cognito_user_dict[key].get("user_name_sub")}", '
            updates_added = True

    if inserts_added:
        sql = f'{inserts[:-2]};'
        print(sql)
        execute_statement(
            sql,
            variables_dict['secret_arn'],
            variables_dict["database_name"],
            variables_dict["database_cluster_arn"]
        )

    if updates_added:
        sql = f'{active_cases} end) {update_condition[:-2]});'
        print(sql)
        execute_statement(
            sql,
            variables_dict['secret_arn'],
            variables_dict["database_name"],
            variables_dict["database_cluster_arn"]
        )

