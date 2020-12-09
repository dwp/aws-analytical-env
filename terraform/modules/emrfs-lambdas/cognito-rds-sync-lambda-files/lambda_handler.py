import os
from aws_sync_caller import get_groups_for_user, get_users_in_userpool, execute_statement


def lambda_handler(event, context):
    variables = get_env_vars()

    cognito_user_dict = get_user_dict_from_cognito(variables['cognito_userpool_id'])
    rds_user_dict = get_user_dict_from_rds(variables)




# Gets env vars passed in from terraform as strings and builds the variables global dict.
def get_env_vars():
    variables = {
        'database_cluster_arn': os.getenv('DATABASE_CLUSTER_ARN'),
        'database_name': os.getenv('DATABASE_NAME'),
        'secret_arn': os.getenv('SECRET_ARN'),
        'cognito_userpool_id': os.getenv('COGNITO_USERPOOL_ID')
    }

    for var in variables:
        if var is None or var == {}:
            raise Exception(f'Variable: {var} has not been provided.')

    return variables


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
            active = list(record[1].values())[0]
            group_name = [''.join(record[2].values())]
            if return_dict.get(user_name) == None:
                return_dict[user_name] = {
                    'active': active,
                    'group_names': group_name,
                }
            else:
                return_dict[user_name]['group_names'].extend(group_name)
    except Exception as e:
        raise e
    return return_dict


# Creates map of all users to their status and groups
def get_user_dict_from_cognito(user_pool_id):
    users = get_users_in_userpool(user_pool_id)

    return_dict = {}

    user_groups = lambda user_name_no_sub: [
        x.get('GroupName') for x in
        get_groups_for_user(user_name_no_sub, user_pool_id)
    ]

    user_object = lambda user_name_no_sub: {
        ''.join([user.get('Username'), user.get('Attributes')[0].get('Value')[0:3]]): {
            'active': user.get('Enabled'),
            'group_names': user_groups(user.get('Username'))
        }
    }

    for user in users:
        return_dict.update(user_object(user))

    return return_dict
