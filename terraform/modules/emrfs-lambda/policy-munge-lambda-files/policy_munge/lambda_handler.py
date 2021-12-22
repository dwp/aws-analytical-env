import copy
import importlib.resources as pkg_resources
import json
import logging
import re
from typing import TypedDict, List, Dict

import policy_munge.aws_caller as aws_caller
from policy_munge.config import get_config, ConfigKeys
from policy_munge.util import str_md5_digest
from policy_munge import resources


logger = logging.getLogger()
logger.level = logging.INFO

# policy json template to be copied and amended as needed
IAM_TEMPLATE = {"Version": "2012-10-17", "Statement": []}
CHARS_IN_EMPTY_IAM_TEMPLATE = 42
CHAR_LIMIT_JSON_POLICY = 6144
CHARS_EMPTY_TAG = 0
CHAR_LIMIT_TAG_VALUE = 200

# vars to filter pii users and policies
COGNITO_PII_GROUP_NAME = "UC_DataScience_PII"
RBAC_PII_DB_SUFFIX = "unredacted"

"""
============================================================================================================
========================================== Policy Munging Lambda ===========================================

The lambda is used to munge policies together, in order to allow larger numbers of policies to be assigned 
to a single IAM role than would otherwise be possible.

 Process: 
 - All roles previously created by the lambda are collated into a list and compared with what is in the rds 
 db and roles present in the db and not in aws are created.
 - All existing AWS policies are collected into a list, the list is filtered to find the policies in the 
 input list.
 - The lambda sets up an list of objects, one for each policy name provided in the policyname list created 
 from the db:
 [
    {
        "policy_name": <String: name of existing policy>,
        "statement": <Array/List: JSON IAM Statment objects>,
        "chars": <Int: number of chars in the statement JSON>,
        "chunk_number": <Int: number relating to which policy this object will be munged into>
    }, 
    ...
 ]
 - The policy statements are munged into a new JSON policy, up to the max char limit dictated by AWS. If 
 the policy reaches the limit, a new policy is started. The JSON is stored in a dict with its name as the key
 - The policies are created
 - The policies are attached to the existing role passed in as an input.
 - The role is tagged with the names of the input policies for visability - the tags undergo a similar 
 process to the policy JSON to ensure they don't hit their char limit. 
 - If a user role is marked for deletion in the db the lambda deletes the policies attached to it, then deletes
  the role
 
============================================================================================================
"""


def lambda_handler(event, context):
    config = get_config()

    cognito_client = aws_caller.create_cognito_client(get_config(ConfigKeys.mgmt_account))
    
    pii_users = aws_caller.get_pii_users(get_config(ConfigKeys.user_pool_id),COGNITO_PII_GROUP_NAME ,cognito_client)
    
    user_info: dict[str, UserInfo] = get_db_user_info()

    pre_creation_existing_role_list = aws_caller.get_emrfs_roles()

    existing_role_list = ensure_roles(
        pre_creation_existing_role_list,
        user_info,
        config[ConfigKeys.assume_role_policy_json]
    )

    # !results in a lot of API calls! TODO: check if it can be restricted to just local scope and by path prefix
    all_policy_list = aws_caller.list_all_policies_in_account()

    for user_name in user_info:
        logging.info(f'Starting to process policies for user: {user_name}')
        # get user's group from cognito
        # supply username without the sub (ie., remove last 3 char)
        # user_groups = aws_caller.get_groups_for_user(user_name[:-3], get_config(ConfigKeys.user_pool_id),cognito_client)

        a_user_filtered_policy_name_list = user_info[user_name]['policy_names']

        # if COGNITO_PII_GROUP_NAME in user_groups:
        if user_name[:-3] in pii_users:
            # user is SC cleared - ie., can view pii data
            a_user_filtered_policy_name_list = user_info[user_name]['policy_names']
        else:
            # user is NOT SC cleared - ie., remove PII policy names from the full user-policy list
            a_user_filtered_policy_name_list = [p for p in user_info[user_name]['policy_names'] if RBAC_PII_DB_SUFFIX not in p ]

        if user_info[user_name]['role_name'] in existing_role_list:
            if user_info[user_name]['active']:

                list_of_policy_objects = get_policy_info(
                    a_user_filtered_policy_name_list,
                    all_policy_list
                )

                statement = create_policy_document_from_template(user_name, get_config(ConfigKeys.s3fs_bucket_arn),
                                                                 get_config(ConfigKeys.s3fs_kms_arn))
                s3fs_access_policy_object = create_policy_object(statement)

                list_of_policy_objects.append(s3fs_access_policy_object)

                logging.info(
                    f'Munging policy statements for {[policy.get("policy_name") for policy in list_of_policy_objects]}')
                dict_of_policy_name_to_munged_policy_objects = chunk_policies_and_return_dict_of_policy_name_to_json(
                    list_of_policy_objects, user_name,
                    user_info[user_name]['role_name']
                )
                logging.info(f'Policy statements successfully munged')

                policies_json = json.dumps(list(dict_of_policy_name_to_munged_policy_objects.values()))
                if not role_needs_update(user_info[user_name]['role_name'], policies_json):
                    logger.info(f"Role {user_info[user_name]['role_name']} does not need to be updated")
                    continue

                remove_existing_user_policies(user_info[user_name]['role_name'], all_policy_list)

                logging.info(f'Creating munged policy/policies for {user_name}...')
                list_of_policy_arns = create_policies_from_dict_and_return_list_of_policy_arns(
                    dict_of_policy_name_to_munged_policy_objects
                )
                logging.info(f'Munged policy/policies created')

                logging.info(f'Attaching munged policy/policies to role for {user_name}...')
                attach_policies_to_role(list_of_policy_arns, user_info[user_name]['role_name'])
                delete_tags(user_info[user_name]['role_name'])

                additional_tags = {
                    **config[ConfigKeys.common_tags],
                    "AttachedPoliciesHash": str_md5_digest(policies_json)
                }

                tag_role_with_policies(
                    a_user_filtered_policy_name_list,
                    user_info[user_name]['role_name'],
                    additional_tags
                )

                logging.info(f'Munged policy/policies attached')

            else:
                logging.info(f'User: {user_name} has been removed from UserPool - removing user IAM resources')
                remove_existing_user_policies(user_info[user_name]['role_name'], all_policy_list)
                logging.info(f'Removing role: {user_info[user_name]["role_name"]}')
                aws_caller.remove_user_role(user_info[user_name]['role_name'])
                logging.info(f'Role: {user_info[user_name]["role_name"]} - Removed')
                logging.info(f'Removed User: {user_name} - IAM resources')

        logging.info(f'Finished processing policies for user: {user_name}')


"""
============================================================================================================
======================================== Helper methods for handler ========================================
============================================================================================================
"""


class UserInfo(TypedDict):
    """
    Holds RBAC database user information
    """
    active: bool
    role_name: str
    policy_names: List[str]


def ensure_roles(existing_role_list, db_user_info, assume_role_document):
    """
    Ensures that all users in database have an IAM role created
    :param existing_role_list: list of roles already present in IAM
    :param db_user_info: user information object
    :param assume_role_document: assume role policy to be attached to the role
    :return: list of all user roles
    """

    roles_after_creation = existing_role_list.copy()
    for user in db_user_info:
        if db_user_info[user]['role_name'] not in existing_role_list \
                and db_user_info[user]['active']:
            logging.info(f'No role found for {user} - Creating role...')
            created_role = aws_caller.create_role_and_await_consistency(db_user_info[user]['role_name'],
                                                                        assume_role_document)
            logging.info(f'Role created for {user}')
            roles_after_creation.append(created_role)
    return roles_after_creation


def role_needs_update(role_name: str, desired_policy_json: str) -> bool:
    """
    Checks whether role needs to be updated based on existing hash

    :param role_name: name of role to be checked
    :type role_name: str
    :param desired_policy_json: JSON string of the desired policy state for the role
    :type desired_policy_json: str
    :return: True if policy needs to be updated, False otherwise
    :rtype: bool
    """

    policy_hash = str_md5_digest(desired_policy_json)

    role_tags = aws_caller.get_all_role_tags(role_name)
    hash_role_tag = next((tag for tag in role_tags if tag["Key"] == "AttachedPoliciesHash"), None)
    return hash_role_tag is None or hash_role_tag["Value"] != policy_hash


# gets list of all policies available then creates a map of policy name to statement json based on requested policies
def get_policy_info(policy_names, all_policy_list):
    def build_policy_object(policy):
        statement = aws_caller.get_policy_statements(policy['Arn'], policy['DefaultVersionId'])
        return (
            {
                'policy_name': policy['PolicyName'],
                'statement': statement,
                'chars': len(json.dumps(statement)),
                'chunk_number': None
            }
        )

    requested_policies = [policy for policy in all_policy_list if policy['PolicyName'] in policy_names]
    policy_objects = list(map(build_policy_object, requested_policies))

    policy_object_names = [policy.get('policy_name') for policy in policy_objects]
    for policy_name in policy_names:
        if policy_name not in policy_object_names:
            raise NameError(f'Policy missing from Map: {policy_name}')

    return policy_objects


# creates json of policy documents mapped to their policy name using iam_policy_template and statements
# from existing policies.
def chunk_policies_and_return_dict_of_policy_name_to_json(policy_object_list, user_name, role_name):
    policy_object_list = assign_chunk_number_to_objects(policy_object_list, CHARS_IN_EMPTY_IAM_TEMPLATE,
                                                        CHAR_LIMIT_JSON_POLICY)
    total_number_of_chunks = policy_object_list[(len(policy_object_list) - 1)]['chunk_number'] + 1
    dict_of_policy_name_to_munged_policy_objects = {}
    for policy in policy_object_list:
        munged_policy_name = f'emrfs_{user_name}-{policy["chunk_number"] + 1}of{total_number_of_chunks}'
        if munged_policy_name in dict_of_policy_name_to_munged_policy_objects:
            dict_of_policy_name_to_munged_policy_objects[munged_policy_name]['Statement'].extend(policy['statement'])
        else:
            iam_policy = copy.deepcopy(IAM_TEMPLATE)
            iam_policy['Statement'] = policy['statement']
            dict_of_policy_name_to_munged_policy_objects[munged_policy_name] = iam_policy

    # checks to see if 20 policy attachment limit is reached before creating policies
    if (len(dict_of_policy_name_to_munged_policy_objects) > 20):
        raise IndexError(f"Maximum policy assignment exceeded for role: {role_name}")
    return dict_of_policy_name_to_munged_policy_objects


# fills chunk_number attribute of object based on AWS imposed character allowance
def assign_chunk_number_to_objects(object_list, start_char, max_char):
    count = 0
    chars = start_char
    for object in object_list:
        if (chars + object['chars']) >= max_char:
            count += 1
            chars = start_char
        object['chunk_number'] = count
        chars += object['chars']
    return object_list


# deletes any existing policies made by the lambda to apply the fresh set to user
def remove_existing_user_policies(role_name, all_policy_list):
    regex = re.compile(fr"{role_name}-\d*of\d*")
    for policy in all_policy_list:
        if regex.match(policy['PolicyName']):
            logging.info(f'Removing policy: {policy["PolicyName"]}')
            aws_caller.remove_policy_being_replaced(policy['Arn'], role_name)
            logging.info(f'Policy: {policy["PolicyName"]} - Removed')


# creates policies in IAM from JSON files and removes JSON files
def create_policies_from_dict_and_return_list_of_policy_arns(dict_of_policy_name_to_munged_policy_objects):
    list_of_policy_arns = []
    for policy in dict_of_policy_name_to_munged_policy_objects:
        prevent_matching_sids(dict_of_policy_name_to_munged_policy_objects[policy].get('Statement'))
        policy_arn = aws_caller.create_policy_from_json_and_return_arn(policy, json.dumps(
            dict_of_policy_name_to_munged_policy_objects[policy]))
        list_of_policy_arns.append(policy_arn)
    return list_of_policy_arns


def prevent_matching_sids(munged_policy_statement):
    sids = {}
    for statement in munged_policy_statement:
        sid = statement.get("Sid")
        if sid and sid in sids.keys():
            sids[sid] += 1
            statement["Sid"] = f'{statement["Sid"]}{sids[sid]}'
        else:
            sids[sid] = 0


def attach_policies_to_role(list_of_policy_arns, role_name):
    for arn in list_of_policy_arns:
        aws_caller.attach_policy_to_role(arn, role_name)


# finds all tags created by this lambda on a given role and deletes them
def delete_tags(role_name):
    tags = aws_caller.get_all_role_tags(role_name)
    regex = re.compile(f"InputPolicies-\d*of\d*")
    tag_name_list = []
    for tag in tags:
        if (regex.match(tag['Key'])):
            tag_name_list.append(tag['Key'])
    if len(tag_name_list) > 0:
        aws_caller.delete_role_tags(tag_name_list, role_name)


# creates tag values mapped to their tag name to avoid hitting the maximum tag per role
def tag_role_with_policies(policy_list: List[str], role_name: str, additional_tags: Dict[str, str]):
    tag_object_list = []
    for name in policy_list:
        tag_object_list.append(
            {
                "policy_name": name,
                "chars": len(name),
                "chunk_number": None
            }
        )
    chunked_tag_object_list = assign_chunk_number_to_objects(tag_object_list,
                                                             CHARS_EMPTY_TAG,
                                                             CHAR_LIMIT_TAG_VALUE)
    tag_keys_to_value_list = {}
    total_number_of_chunks = chunked_tag_object_list[(len(chunked_tag_object_list) - 1)]['chunk_number'] + 1
    for tag in chunked_tag_object_list:
        tag_key = f'InputPolicies-{tag["chunk_number"] + 1}of{total_number_of_chunks}'
        if tag_key in tag_keys_to_value_list:
            tag_keys_to_value_list[tag_key].append(tag['policy_name'])
        else:
            tag_keys_to_value_list[tag_key] = [tag['policy_name']]

    if len(tag_keys_to_value_list) > (50 - len(additional_tags)):
        raise IndexError("Tag limit for role exceeded")

    tags = [
        *map(lambda key: {'Key': key, 'Value': '/'.join(tag_keys_to_value_list[key])}, tag_keys_to_value_list),
        *map(lambda key: {'Key': key, 'Value': additional_tags[key]}, additional_tags)
    ]

    aws_caller.tag_role(role_name, tags)


def get_db_user_info() -> Dict[str, UserInfo]:
    """
    queries user database and returns a dict, keyed by user_name with
    child values of: active (if user is marked for deletion),
    policy_names (list of policies to assign to the user's role)
    and role_name
    """

    return_dict: Dict[str, UserInfo] = {}
    sql = f"""SELECT User.username, User.active, Policy.policyname
        FROM User
        JOIN UserGroup ON User.id = UserGroup.userId
        JOIN GroupPolicy ON UserGroup.groupId = GroupPolicy.groupId
        JOIN Policy ON GroupPolicy.policyId = Policy.id;"""
    response = aws_caller.execute_statement(sql)
    if len(response['records']) > 0:
        for record in response['records']:
            user_name = ''.join(record[0].values())
            active = list(record[1].values())[0]
            policy_name = ''.join(record[2].values())
            if return_dict.get(user_name) is None:
                return_dict[user_name] = {
                    'active': active,
                    'policy_names': ["emrfs_iam", policy_name],
                    'role_name': f'emrfs_{user_name}',
                }
            else:
                if policy_name not in return_dict[user_name]['policy_names']:
                    return_dict[user_name]['policy_names'].append(policy_name)
    else:
        raise ValueError("No records returned from RDS")
    return return_dict


def create_policy_document_from_template(user_name, bucket_id, kms_arn):
    with pkg_resources.open_text(resources, 's3fs_policy_template.json') as template_file:
        statement = json.load(template_file)

    home_key_arn = aws_caller.get_kms_arn(f'alias/{user_name}-home')
    if home_key_arn is None:
        logger.warning(f'No KMS found in account for alias: \"alias/{user_name}-home\"')

    s3fsaccessdocument = statement[0].get('Resource')
    s3fskmsaccessdocument = statement[1].get('Resource')
    s3fslist = statement[2].get('Resource')

    s3fsaccessdocument.append(
        f'{bucket_id}/home/{user_name}/*'
    )

    s3fskmsaccessdocument.extend([
        item for item in [kms_arn, home_key_arn] if item is not None
    ])

    s3fslist.append(
        bucket_id
    )
    return statement


def create_policy_object(policy_dict):
    return {
        'policy_name': 's3fsAccess',
        'statement': policy_dict,
        'chars': len(json.dumps(policy_dict)),
        'chunk_number': None
    }
