import logging
import os
from typing import List

import boto3
import botocore
from botocore.config import Config

from policy_munge.config import get_config, ConfigKeys

logger = logging.getLogger()
logger.level = logging.INFO

boto_config = Config(
    retries={
        'max_attempts': 5,
        'mode': 'standard'
    }
)

iam_client = boto3.client('iam', config=boto_config)
rds_data_client = boto3.client('rds-data')
sts_client = boto3.client('sts')
kms_client = boto3.client('kms')


"""
============================================================================================================
=================================== Helper methods that interact with AWS ==================================
============================================================================================================
"""


# assumes mgmt role to set up cognito client associated with mgmt account
def create_cognito_client(mgmt_account_role_arn):
    mgmt_account = sts_client.assume_role(
        RoleArn=mgmt_account_role_arn,
        RoleSessionName="mgmt_cognito_rds_sync_lambda"
    )
    # create cognito client using the assumed role credentials in mgmt acc
    cognito_client = boto3.client(
        'cognito-idp',
        aws_access_key_id=mgmt_account['Credentials']['AccessKeyId'],
        aws_secret_access_key=mgmt_account['Credentials']['SecretAccessKey'],
        aws_session_token=mgmt_account['Credentials']['SessionToken']
    )
    return cognito_client


def get_groups_for_user(user_name_no_sub, user_pool_id, cognito_client):
    try:
        response = cognito_client.admin_list_groups_for_user(
            Username=user_name_no_sub,
            UserPoolId=user_pool_id,
        )
    except cognito_client.exceptions.UserNotFoundException:
        user_name = cognito_client.list_users(
            UserPoolId=user_pool_id,
            Filter=f'preferred_username=\"{user_name_no_sub}\"'
        ).get('Users')[0].get('Username')

        response = cognito_client.admin_list_groups_for_user(
            Username=user_name,
            UserPoolId=user_pool_id,
        )
    return [group.get('GroupName') for group in response.get('Groups')]


# returns list of usernames those are in PII group
def get_pii_users(user_pool_id, pii_group_name, cognito_client):
    paginated_pii_users = []
    tmp_pii_users = []
    pii_users = []
    next_token=''
    while next_token is not None:
        if next_token:
            paginated_pii_users = cognito_client.list_users_in_group(
            UserPoolId = user_pool_id,
            GroupName = pii_group_name,
            NextToken = next_token
            )
        else:
            paginated_pii_users = cognito_client.list_users_in_group(
            UserPoolId = user_pool_id,
            GroupName = pii_group_name,
        )
        
        # get next page token
        if set(["NextToken","Next"]).intersection(set(paginated_pii_users)):
            next_token = paginated_pii_users["NextToken"] if "NextToken" in paginated_pii_users else paginated_pii_users['Next']
        else:
            next_token = None
        
        # put paginated user objects into a temp list
        tmp_pii_users.append(paginated_pii_users['Users'])
    
    # remove other un-necessary meta and produce list with just usernames
    # considering adfs and non-adfs users
    for p_list in tmp_pii_users:
        for u in p_list:
            if u['UserStatus'] != 'EXTERNAL_PROVIDER':
                pii_users.append(u['Username'])
            elif u['UserStatus'] == 'EXTERNAL_PROVIDER':
                for a in u['Attributes']:
                    if a['Name'] == 'preferred_username':
                        pii_users.append(a['Value'])
    return pii_users


def list_all_policies_in_account():
    policy_list = []
    get_paginated_results_using_marker(
        aws_api_reponse=iam_client.list_policies(Scope='All'),
        list=policy_list,
        iam_client_call=iam_client.list_policies,
        field_name='Policies',
        client_call_args={'Scope': 'All'}
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
def get_policy_statements(arn, default_version_id) -> List[str]:
    policy_version = iam_client.get_policy_version(
        PolicyArn=arn,
        VersionId=default_version_id
    )
    return policy_version['PolicyVersion']['Document']['Statement']


# creates a new policy in AWS, waits for it to exist, then returns the ARN
def create_policy_from_json_and_return_arn(policy_name, json_document):
    policy = iam_client.create_policy(
        Path="/emrfs/",
        PolicyName=policy_name,
        PolicyDocument=json_document
    )
    policy_arn = policy['Policy']['Arn']
    wait_for_policy_to_exist(policy_arn)
    return policy_arn


# detaches and deletes policies from a role in order for them to be replaced
def remove_policy_being_replaced(policy_arn, role_name):
    # removes from role
    try:
        iam_client.detach_role_policy(
            RoleName=role_name,
            PolicyArn=policy_arn
        )
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchEntity':
            logger.info(f'Policy: \"{os.path.basename(policy_arn)}\" not found for role: \"{role_name}\".')
        else:
            raise e

    # deletes policy versions if exist
    versions_list = iam_client.list_policy_versions(
        PolicyArn=policy_arn
    )['Versions']

    version_ids = [version['VersionId'] for version in versions_list if version['IsDefaultVersion'] is False]

    for version_id in version_ids:
        iam_client.delete_policy_version(
            PolicyArn=policy_arn,
            VersionId=version_id
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


#
def get_emrfs_roles():
    """
    Gets list of all roles previously created by this lambda
    :return: list of role names
    """
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


def create_role_and_await_consistency(role_name, assume_role_doc):
    iam_client.create_role(
        Path="/emrfs/",
        RoleName=role_name,
        AssumeRolePolicyDocument=assume_role_doc
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
def execute_statement(sql: str):
    response = rds_data_client.execute_statement(
        secretArn=get_config(ConfigKeys.database_secret_arn),
        database=get_config(ConfigKeys.database_name),
        resourceArn=get_config(ConfigKeys.database_cluster_arn),
        sql=sql
    )
    return response


# takes an alias or key id and returns key arn or None, if alias/id is not found in account
def get_kms_arn(id_or_alias):
    try:
        key_details = kms_client.describe_key(
            KeyId=id_or_alias,
        ).get('KeyMetadata')
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == 'NotFoundException':
            return None
        else:
            raise e

    return key_details.get('Arn')
