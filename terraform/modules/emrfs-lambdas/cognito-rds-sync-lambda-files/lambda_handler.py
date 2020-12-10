import os
from aws_sync_caller import get_groups_for_user, get_users_in_userpool, execute_statement, create_cognito_client
variables = {}

def lambda_handler(event, context):
    get_env_vars()
    create_cognito_client(variables['MGMT_ACCOUNT_ROLE_ARN'])

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
def get_user_dict_from_rds(variables):
    return_dict = {}
    sql = f'SELECT User.userName, User.active, `Group`.groupname \
    FROM User \
    JOIN UserGroup ON User.id = UserGroup.userId \
    JOIN `Group` ON UserGroup.groupId = `Group`.id;'

    try:
        response = execute_statement(
            sql,
            variables['secret_arn'],
            variables["database_name"],
            variables["database_cluster_arn"]
        )
        for record in response['records']:
            user_name = ''.join(record[0].values())
            user_name_raw = user_name[0:-3]
            active = list(record[1].values())[0]
            group_name = [''.join(record[2].values())]
            if return_dict.get(user_name_raw) == None:
                return_dict[user_name[0:-3]] = {
                    'active': active,
                    'group_names': group_name,
                    'user_name_sub': user_name
                }
            else:
                return_dict[user_name_raw]['group_names'].extend(group_name)
    except Exception as e:
        raise e
    return return_dict


# queries Cognito userpool for all user data and returns a dict mapping username to active, group_names and user_name_sub
def get_user_dict_from_cognito(user_pool_id):
    users = get_users_in_userpool(user_pool_id)

    return_dict = {}
    user_groups = lambda user_name_no_sub: [
        x.get('GroupName') for x in
        get_groups_for_user(user_name_no_sub, user_pool_id)
    ]

    user_object = lambda user_name_no_sub: {
        user.get('Username'): {
            'active': user.get('Enabled'),
            'group_names': user_groups(user.get('Username')),
            'user_name_sub':''.join([user.get('Username'), user.get('Attributes')[0].get('Value')[0:3]])
        }
    }

    for user in users:
        return_dict.update(user_object(user))

    return return_dict

# compares rds user dict to cognito user dict and updates rds with values from cognito
def sync_values(cognito_user_dict, rds_user_dict, variables):
    sql=''
    for key, val in cognito_user_dict.items():
        if key in rds_user_dict:
            if rds_user_dict[key].get('active') != cognito_user_dict[key].get('active'):
                # sql statement to update existing user status
                sql = ''.join([
                    sql,
                    f'UPDATE User SET active = {cognito_user_dict[key].get("active")} WHERE userName = "{key}"; '
                ])
        else:
            # sql to add user to user table
            sql = ''.join([
                sql,
                f'INSERT INTO User (userName, active) VALUES ("{key}", {cognito_user_dict[key].get("active")}); '
            ])
    print(sql)
    try:
        execute_statement(
            sql,
            variables['secret_arn'],
            variables["database_name"],
            variables["database_cluster_arn"]
        )
    except Exception as e:
        raise e
