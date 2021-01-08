import json
import copy
import re
import os

from aws_caller import list_all_policies_in_account, get_policy_statement_as_list, \
    create_policy_from_json_and_return_arn, attach_policy_to_role, \
    remove_policy_being_replaced, tag_role, get_all_role_tags, delete_role_tags, \
    execute_statement, create_role_and_await_consistency, get_emrfs_roles, remove_user_role

# policy json template to be copied and amended as needed
iam_template = {"Version": "2012-10-17", "Statement": []}
chars_in_empty_iam_template = 42
char_limit_of_json_policy = 6144
chars_in_empty_tag = 0
char_limit_for_tag_value = 200
variables = {}

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
    get_env_vars()

    user_state_and_policy = get_user_userstatus_policy_dict(variables)

    pre_creation_existing_role_list = get_emrfs_roles()

    existing_role_list = check_roles_exist_and_create_if_not(
        pre_creation_existing_role_list,
        user_state_and_policy,
        variables['assume_role_policy_json']
    )

    all_policy_list = list_all_policies_in_account()

    for user_name in user_state_and_policy:
        if user_state_and_policy[user_name]['role_name'] in existing_role_list:
            if user_state_and_policy[user_name]['active']:

                list_of_policy_objects = create_policy_object_list_from_policy_name_list(
                    user_state_and_policy[user_name]['policy_names'],
                    all_policy_list
                )

                statement = create_policy_document_from_template(user_name, user_state_and_policy[user_name].get('group_names'), variables)
                s3fs_access_policy_object = create_policy_object(statement)

                list_of_policy_objects.append(s3fs_access_policy_object)

                dict_of_policy_name_to_munged_policy_objects = chunk_policies_and_return_dict_of_policy_name_to_json(
                    list_of_policy_objects, user_name,
                    user_state_and_policy[user_name]['role_name']
                )

                remove_existing_user_policies(user_state_and_policy[user_name]['role_name'], all_policy_list)

                list_of_policy_arns = create_policies_from_dict_and_return_list_of_policy_arns(
                    dict_of_policy_name_to_munged_policy_objects
                )

                attach_policies_to_role(list_of_policy_arns, user_state_and_policy[user_name]['role_name'])
                delete_tags(user_state_and_policy[user_name]['role_name'])
                tag_role_with_policies(
                    user_state_and_policy[user_name]['policy_names'],
                    user_state_and_policy[user_name]['role_name'],
                    variables['common_tags']
                )

            else:
                remove_existing_user_policies(user_state_and_policy[user_name]['role_name'], all_policy_list)
                remove_user_role(user_state_and_policy[user_name]['role_name'])


"""
============================================================================================================
======================================== Helper methods for handler ========================================
============================================================================================================
"""


# Gets env vars passed in from terraform as strings and builds the variables global dict.
def get_env_vars():
    common_tags_string = os.getenv('COMMON_TAGS')
    tag_separator = ","
    key_val_separator = ":"

    variables['database_cluster_arn'] = os.getenv('DATABASE_CLUSTER_ARN')
    variables['database_name'] = os.getenv('DATABASE_NAME')
    variables['secret_arn'] = os.getenv('SECRET_ARN')
    variables['common_tags'] ={}
    variables['assume_role_policy_json'] = os.getenv('ASSUME_ROLE_POLICY_JSON')
    variables['s3fs_bucket_arn'] = os.getenv('FILE_SYSTEM_BUCKET_ARN')
    variables['region'] = os.getenv('REGION')
    variables['account'] = os.getenv('ACCOUNT')

    common_tags = common_tags_string.split(tag_separator)
    for tag in common_tags:
        tag_key_val_list = tag.split(key_val_separator)
        variables['common_tags'][tag_key_val_list[0]] = tag_key_val_list[1]

    for var in variables:
        if var is None or var == {}:
            raise NameError(f'Variable: {var} has not been provided.')
    return variables


# loops through the desired state (from RDS) and what exists in AWS and creates any missing roles
def check_roles_exist_and_create_if_not(existing_role_list, user_state_and_policy, assume_role_document):
    roles_after_creation = existing_role_list.copy()
    for user in user_state_and_policy:
        if user_state_and_policy[user]['role_name'] not in existing_role_list \
                and user_state_and_policy[user]['active']:
            created_role = create_role_and_await_consistency(user_state_and_policy[user]['role_name'],
                                                             assume_role_document)
            roles_after_creation.append(created_role)
    return roles_after_creation


# gets list of all policies available then creates a map of policy name to statement json based on requested policies
def create_policy_object_list_from_policy_name_list(names, all_policy_list):
    policy_object_list = []
    for policy in all_policy_list:
        if (policy['PolicyName'] in names):
            statement = get_policy_statement_as_list(policy['Arn'], policy['DefaultVersionId'])
            policy_object_list.append(
                {
                    'policy_name': policy['PolicyName'],
                    'statement': statement,
                    'chars': len(json.dumps(statement)),
                    'chunk_number': None
                }
            )
    verify_policies(names, policy_object_list)
    return policy_object_list


# checks original input against map used for policy
def verify_policies(names, list_of_policy_objects):
    policy_object_names = [policy.get('policy_name') for policy in list_of_policy_objects]
    for policy_name in names:
        if policy_name not in policy_object_names:
            raise NameError(f'Policy missing from Map: {policy_name}')


# creates json of policy documents mapped to their policy name using iam_policy_template and statements
# from existing policies.
def chunk_policies_and_return_dict_of_policy_name_to_json(policy_object_list, user_name, role_name):
    policy_object_list = assign_chunk_number_to_objects(policy_object_list, chars_in_empty_iam_template,
                                                         char_limit_of_json_policy)
    total_number_of_chunks = policy_object_list[(len(policy_object_list) - 1)]['chunk_number'] +1
    dict_of_policy_name_to_munged_policy_objects = {}
    for policy in policy_object_list:
        munged_policy_name = f'emrfs_{user_name}-{policy["chunk_number"] + 1}of{total_number_of_chunks}'
        if munged_policy_name in dict_of_policy_name_to_munged_policy_objects:
            dict_of_policy_name_to_munged_policy_objects[munged_policy_name]['Statement'].extend(policy['statement'])
        else:
            iam_policy = copy.deepcopy(iam_template)
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
    regex = re.compile(f"{role_name}-\d*of\d*")
    for policy in all_policy_list:
        if (regex.match(policy['PolicyName'])):
            remove_policy_being_replaced(policy['Arn'], role_name)


# creates policies in IAM from JSON files and removes JSON files
def create_policies_from_dict_and_return_list_of_policy_arns(dict_of_policy_name_to_munged_policy_objects):
    list_of_policy_arns = []
    for policy in dict_of_policy_name_to_munged_policy_objects:
        policy_arn = create_policy_from_json_and_return_arn(policy, json.dumps(
            dict_of_policy_name_to_munged_policy_objects[policy]))
        list_of_policy_arns.append(policy_arn)
    return list_of_policy_arns


def attach_policies_to_role(list_of_policy_arns, role_name):
    for arn in list_of_policy_arns:
        attach_policy_to_role(arn, role_name)


# finds all tags created by this lambda on a given role and deletes them
def delete_tags(role_name):
    tags = get_all_role_tags(role_name)
    regex = re.compile(f"InputPolicies-\d*of\d*")
    tag_name_list = []
    for tag in tags:
        if (regex.match(tag['Key'])):
            tag_name_list.append(tag['Key'])
    if (len(tag_name_list) > 0):
        delete_role_tags(tag_name_list, role_name)


# creates tag values mapped to their tag name to avoid hitting the maximum tag per role
def tag_role_with_policies(policy_list, role_name, common_tags):
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
                                                              chars_in_empty_tag,
                                                              char_limit_for_tag_value)
    tag_keys_to_value_list = {}
    total_number_of_chunks = chunked_tag_object_list[(len(chunked_tag_object_list) - 1)]['chunk_number'] + 1
    for tag in chunked_tag_object_list:
        tag_key = f'InputPolicies-{tag["chunk_number"] + 1}of{total_number_of_chunks}'
        if tag_key in tag_keys_to_value_list:
            tag_keys_to_value_list[tag_key].append(tag['policy_name'])
        else:
            tag_keys_to_value_list[tag_key] = [tag['policy_name']]

    if len(tag_keys_to_value_list) > (50-len(common_tags)):
        raise IndexError("Tag limit for role exceeded")

    tag_list = create_tag_list(tag_keys_to_value_list, common_tags)

    tag_role(role_name, tag_list)


# creates a list of tag objects to be added to a role
def create_tag_list(tag_keys_to_value_list, common_tags):
    separator = '/'
    tag_list = []
    for tag in common_tags:
        tag_list.append(
            {
                'Key': tag,
                'Value': common_tags[tag]
            }
        )
    for tag in tag_keys_to_value_list:
        tag_list.append(
            {
                'Key': tag,
                'Value': separator.join(tag_keys_to_value_list[tag])
            }
        )
    return tag_list


# queries RDS and returns a dict, indexed by user_name with child values of: active (if user is marked for deletion),
# policy_names (list of policies to assign to the user's role), group_name (list of groups the user is assigned to)
# and role_name
def get_user_userstatus_policy_dict(variables):
    return_dict = {}
    sql = f'SELECT User.username, User.active, Policy.policyname, `Group`.groupname \
        FROM User \
        JOIN UserGroup ON User.id = UserGroup.userId \
        JOIN `Group` ON UserGroup.groupId = `Group`.id \
        JOIN GroupPolicy ON UserGroup.groupId = GroupPolicy.groupId \
        JOIN Policy ON GroupPolicy.policyId = Policy.id;'
    response = execute_statement(
        sql,
        variables['secret_arn'],
        variables["database_name"],
        variables["database_cluster_arn"]
    )
    if len(response['records']) > 0:
        for record in response['records']:
            user_name = ''.join(record[0].values())
            active = list(record[1].values())[0]
            policy_name = ''.join(record[2].values())
            group_name = ''.join(record[3].values())
            if return_dict.get(user_name) == None:
                return_dict[user_name] = {
                    'active': active,
                    'policy_names': ["emrfs_iam", policy_name],
                    'group_names' : [group_name],
                    'role_name': f'emrfs_{user_name}'
                }
            else:
                if policy_name not in return_dict[user_name]['policy_names']:
                    return_dict[user_name]['policy_names'].append(policy_name)
                if group_name not in return_dict[user_name]['group_names']:
                    return_dict[user_name]['group_names'].append(group_name)
    else:
        raise ValueError("No records returned from RDS")
    return return_dict


def create_policy_document_from_template(user_name, group_names, variables):
    with open('s3fs_policy_template.json', 'r') as statement_raw:
        statement = json.load(statement_raw)

    s3fsaccessdocument = statement[0].get('Resource')
    s3fskmsaccessdocument = statement[1].get('Resource')
    s3fslist = statement[2].get('Resource')

    s3fsaccessdocument.extend([
        f'{variables["s3fs_bucket_arn"]}/*',
        f'arn:aws:kms:{variables["region"]}:{variables["account"]}:alias/{user_name}-home'
    ])

    for group_name in group_names:
        s3fsaccessdocument.append(
            f'arn:aws:kms:{variables["region"]}:{variables["account"]}:alias/{group_name}-shared'
        )
        s3fskmsaccessdocument.append(
            f'arn:aws:kms:{variables["region"]}:{variables["account"]}:alias/{group_name}-shared'
        )

    s3fskmsaccessdocument.extend([
        f'{variables["s3fs_bucket_arn"]}/*',
        f'arn:aws:kms:{variables["region"]}:{variables["account"]}:alias/{user_name}-home'

    ])

    s3fslist.append(
        variables["s3fs_bucket_arn"]
    )

    return statement


def create_policy_object(policy_dict):
    return {
        'policy_name': 's3fsAccess',
        'statement': policy_dict,
        'chars': len(json.dumps(policy_dict)),
        'chunk_number': None
    }
