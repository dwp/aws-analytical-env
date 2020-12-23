import boto3

iam_client = boto3.client('iam')
rds_data_client = boto3.client('rds-data')

"""
============================================================================================================
=================================== Helper methods that interact with AWS ==================================
============================================================================================================
"""


def list_all_policies_in_account():
    policy_list = []
    get_paginated_results_using_marker(
        aws_api_reponse=iam_client.list_policies(Scope='All',PathPrefix='/emrfs/'),
        list=policy_list,
        iam_client_call=iam_client.list_policies,
        field_name='Policies',
        client_call_args={'Scope': 'All', 'PathPrefix': '/emrfs/'}
    )
    return policy_list


# cycles through paginated API response, using a marker, and returns full list
def get_paginated_results_using_marker(aws_api_reponse, list, iam_client_call, field_name=None, client_call_args={}):
    if field_name == None:
        list.extend(aws_api_reponse)
    else:
        list.extend(aws_api_reponse[field_name])
    if (aws_api_reponse['IsTruncated']):
        res = iam_client_call(Marker=aws_api_reponse['Marker'], **client_call_args)
        get_paginated_results_using_marker(res, list, iam_client_call, field_name, client_call_args)
    else:
        return list


# returns a list of JSON policy statements from an existing policy
def get_policy_statement_as_list(arn, default_version_id):
    policy_version = iam_client.get_policy_version(
        PolicyArn=arn,
        VersionId=default_version_id
    )
    return policy_version['PolicyVersion']['Document']['Statement']


# creates a new policy in AWS, waits for it to exist, then returns the ARN
def create_policy_from_json_and_return_arn(policy_name, json_document):
    policy = iam_client.create_policy(
        PolicyName=policy_name,
        PolicyDocument=json_document
    )
    policy_arn = policy['Policy']['Arn']
    wait_for_policy_to_exist(policy_arn)
    return policy_arn


# detaches and deletes policies from a role in order for them to be replaced
def remove_policy_being_replaced(policy_arn, role_name):
    # removes from role
    iam_client.detach_role_policy(
        RoleName=role_name,
        PolicyArn=policy_arn
    )
    # deletes policy
    iam_client.delete_policy(
        PolicyArn=policy_arn
    )


def attach_policy_to_role(policy_arn, role):
    iam_client.attach_role_policy(
        RoleName=role,
        PolicyArn=policy_arn
    )


def wait_for_policy_to_exist(arn):
    waiter = iam_client.get_waiter('policy_exists')
    waiter.wait(
        PolicyArn=arn,
        WaiterConfig={
            'Delay': 5,
            'MaxAttempts': 6
        }
    )


# returns list of names of all roles previously created by this lambda
def get_emrfs_roles():
    role_list = []
    path_prefix = '/emrfs/'
    aws_api_reponse = iam_client.list_roles(
        PathPrefix=path_prefix,
    )
    get_paginated_results_using_marker(
        aws_api_reponse=aws_api_reponse,
        list=role_list,
        iam_client_call=iam_client.list_roles,
        field_name='Roles',
        client_call_args={'PathPrefix': path_prefix})

    return_list = []
    for role in role_list:
        return_list.append(role['RoleName'])

    return return_list


def create_role_and_await_consistency(role_name, assumeRoleDoc):
    iam_client.create_role(
        Path="/emrfs/",
        RoleName=role_name,
        AssumeRolePolicyDocument=assumeRoleDoc
    )
    waiter = iam_client.get_waiter('role_exists')
    waiter.wait(
        RoleName=role_name,
        WaiterConfig={
            'MaxAttempts': 40
        }
    )
    return role_name


# returns all tags associated with the given role
def get_all_role_tags(role_name):
    result = iam_client.list_role_tags(
        RoleName=role_name,
    )
    result_list = []
    get_paginated_results_using_marker(
        aws_api_reponse=result,
        list=result_list,
        iam_client_call=iam_client.list_role_tags,
        field_name='Tags',
        client_call_args={'RoleName': role_name}
    )
    return result_list


def tag_role(role_name, tag_list):
    iam_client.tag_role(
        RoleName=role_name,
        Tags=tag_list
    )


def delete_role_tags(tag_name_list, role_name):
    iam_client.untag_role(
        RoleName=role_name,
        TagKeys=tag_name_list
    )


def remove_user_role(role_name):
    iam_client.delete_role(
        RoleName=role_name
    )


# connects to RDS instance and executes the SQL statement passed in
def execute_statement(sql, db_credentials_secrets_store_arn, database_name, db_cluster_arn):
    response = rds_data_client.execute_statement(
        secretArn=db_credentials_secrets_store_arn,
        database=database_name,
        resourceArn=db_cluster_arn,
        sql=sql
    )
    return response
