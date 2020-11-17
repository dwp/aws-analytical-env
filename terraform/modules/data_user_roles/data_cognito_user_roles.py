import sys
import boto3
import json
import math
from functools import reduce


def get_session(role_arn):
    creds = boto3.client('sts').assume_role(
        RoleArn=role_arn,
        RoleSessionName="CognitoUserGetIamRoles"
    )['Credentials']

    return boto3.Session(
        aws_access_key_id=creds['AccessKeyId'],
        aws_secret_access_key=creds['SecretAccessKey'],
        aws_session_token=creds['SessionToken'])


def get_cognito_users(cognitoidp_client, user_pool_id):
    res = cognitoidp_client.list_users(
        UserPoolId=user_pool_id,
        Filter="cognito:user_status=\"CONFIRMED\""
    )
    return res['Users']


def get_roles_for_users(usernames):
    return dict(map(lambda user: (user, "arn:test_role"), usernames))


def main():
    tf_input = json.loads(sys.stdin.read())

    for var in ['role', 'user_pool_id']:
        if var not in tf_input:
            sys.stderr.write("Missing required variable {}".format(var))
            sys.exit(1)

    session = get_session(tf_input['role'])

    users = get_cognito_users(session.client('cognito-idp'), tf_input['user_pool_id'])
    users_with_roles = get_roles_for_users(map(lambda user_obj: user_obj['Username'], users))

    result = {
        'users': json.dumps(users_with_roles),
        'num_security_configs': str(int(math.ceil(
            sum(map(lambda key: len(key) + len(users_with_roles[key]) + 100, users_with_roles.keys())) / 60000.0)))
    }

    print(json.dumps(result))


if __name__ == '__main__':
    main()
