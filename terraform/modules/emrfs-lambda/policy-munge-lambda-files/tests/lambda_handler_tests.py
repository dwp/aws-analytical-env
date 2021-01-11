import lambda_handler
from unittest import TestCase
import copy
from mock import call, patch

iam_template = {"Version": "2012-10-17", "Statement": []}

variables = {}
variables['database_cluster_arn'] = 'arn:12345432::test_arn'
variables['database_name'] = 'test_db'
variables['secret_arn'] = 'arn:12345432::secret_test_arn'
variables['common_tags'] = {'tag1key': 'tag1val', 'tag2key': 'tag2val'}
variables['assume_role_policy_json'] = '{"json": "policy string"}'
variables['s3fs_bucket_arn'] = 'arn:12345432::s3_test_arn'
variables['region'] = 'eu-west-7'
variables['account'] = '1234567'
variables['mgmt_account'] = 'arn:12345432::mgmt_acc_test_arn'
variables['user_pool_id'] = '12345432_ea2'

mocked_db_response = {
    'numberOfRecordsUpdated': 0,
    'records': [
        [{'stringValue': 'user_one'}, {'booleanValue': False}, {'stringValue': 'policy_one'}, {'stringValue': 'group_one'}],
        [{'stringValue': 'user_two'}, {'booleanValue': True}, {'stringValue': 'policy_one'}, {'stringValue': 'group_two'}],
        [{'stringValue': 'user_one'}, {'booleanValue': False}, {'stringValue': 'policy_two'}, {'stringValue': 'group_two'}],
    ]
}

mocked_user_dict_without_groups = {
    'user_one': {
        'active': False,
        'policy_names': ['emrfs_iam', 'policy_one', 'policy_two'],
        'role_name': 'emrfs_user_one',
        'group_names': []
    },
    'user_two': {
        'active': True,
        'policy_names': ['emrfs_iam', 'policy_one'],
        'role_name': 'emrfs_user_two',
        'group_names': []
    }
}

mocked_user_dict = {
    'user_one': {
        'active': False,
        'policy_names': ['emrfs_iam', 'policy_one', 'policy_two'],
        'role_name': 'emrfs_user_one',
        'group_names': ['group_one', 'group_two']
    },
    'user_two': {
        'active': True,
        'policy_names': ['emrfs_iam', 'policy_one'],
        'role_name': 'emrfs_user_two',
        'group_names': ['group_two']
    }
}

mocked_policy_object_list = [
    {'policy_name': 'policy_one', 'statement': [{'test': 'statement1'}], 'chars': 23, 'chunk_number': None},
    {'policy_name': 'policy_three', 'statement': [{'test': 'statement2'}], 'chars': 23, 'chunk_number': None}
]

mocked_all_policy_list = [
    {
        'PolicyName': 'policy_one',
        'Arn': 'arn:iam:123432/Policy/test1',
        'DefaultVersionId': 'id1',
    },
    {
        'PolicyName': 'policy_two',
        'Arn': 'arn:iam:123432/Policy/test2',
        'DefaultVersionId': 'id2',
    },
    {
        'PolicyName': 'policy_three',
        'Arn': 'arn:iam:123432/Policy/test3',
        'DefaultVersionId': 'id3',
    },
    {
        'PolicyName': 'emrfs_user_one-1of2',
        'Arn': 'arn:iam:123432/Policy/emrfs_test1',
        'DefaultVersionId': 'emrfs_id1',
    },
    {
        'PolicyName': 'emrfs_user_one-2of2',
        'Arn': 'arn:iam:123432/Policy/emrfs_test2',
        'DefaultVersionId': 'emrfs_id2',
    },
]

mocked_role_tags_response = [
    {
        'Key': 'InputPolicies-1of20',
        'Value': 'to_be_removed'
    },
    {
        'Key': 'InputPolicies-18of20',
        'Value': 'to_be_removed'
    },
    {
        'Key': 'Important-Tag',
        'Value': 'to_be_kept'
    }
]

mock_statement_one =   {
    "Sid": "s3fsaccessdocument",
    "Effect": "Allow",
    "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:PutObjectAcl",
        "s3:GetObjectVersion",
        "s3:DeleteObject"
    ],
    "Resource": ["arn:12345432::s3_test_arn/*", "arn:aws:kms:eu-west-7:1234567:alias/test_user-home", "arn:aws:kms:eu-west-7:1234567:alias/group_one-shared", "arn:aws:kms:eu-west-7:1234567:alias/group_two-shared"]
}

mock_statement_two =   {
    "Sid": "s3fskmsaccessdocument",
    "Effect": "Allow",
    "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:DescribeKey",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*"
    ],
    "Resource":  ['arn:aws:kms:eu-west-7:1234567:alias/group_one-shared', 'arn:aws:kms:eu-west-7:1234567:alias/group_two-shared', 'arn:12345432::s3_test_arn/*', 'arn:aws:kms:eu-west-7:1234567:alias/test_user-home']
}

mock_statement_three = {
    "Sid": "s3fslist",
    "Effect": "Allow",
    "Action": [
        "s3:ListBucket"
    ],
    "Resource": ["arn:12345432::s3_test_arn"]
}


class LambdaHandlerTests(TestCase):

    @patch('lambda_handler.os.getenv')
    def test_get_env_vars(self, mock_get_env):
        mock_get_env.side_effect = ["tag1:val1,tag2:val2,tag3:val3", variables['database_cluster_arn'],
                                    variables['database_name'], variables['secret_arn'],
                                    variables['assume_role_policy_json'],
                                    variables['s3fs_bucket_arn'],
                                    variables['region'],
                                    variables['account'],
                                    variables['mgmt_account'],
                                    variables['user_pool_id']
                                    ]
        lambda_handler.get_env_vars()

        assert lambda_handler.variables['common_tags']['tag1'] == 'val1'
        assert lambda_handler.variables['common_tags']['tag2'] == 'val2'
        assert lambda_handler.variables['common_tags']['tag3'] == 'val3'
        assert lambda_handler.variables['database_cluster_arn'] == variables['database_cluster_arn']
        assert lambda_handler.variables['database_name'] == variables['database_name']
        assert lambda_handler.variables['secret_arn'] == variables['secret_arn']
        assert lambda_handler.variables['assume_role_policy_json'] == variables['assume_role_policy_json']
        assert lambda_handler.variables['s3fs_bucket_arn'] == variables['s3fs_bucket_arn']
        assert lambda_handler.variables['mgmt_account'] == variables['mgmt_account']
        assert lambda_handler.variables['user_pool_id'] == variables['user_pool_id']


    @patch('aws_caller.execute_statement')
    def test_get_user_userstatus_policy_dict(self, mock_execute_statement):
        mock_execute_statement.side_effect = [mocked_db_response, {'numberOfRecordsUpdated': 0, 'records': []}]
        result1 = lambda_handler.get_user_userstatus_policy_dict(variables)

        assert result1 == mocked_user_dict_without_groups
        self.assertRaises(
            ValueError,
            lambda_handler.get_user_userstatus_policy_dict,
            variables
        )

    @patch('aws_caller.create_role_and_await_consistency')
    def test_check_roles_exist_and_create_if_not(self, mock_create_role_and_await_consistency):
        one_role_does_not_exist = ['emrfs_user_one']
        both_roles_exist = ['emrfs_user_one', 'emrfs_user_two']
        mock_create_role_and_await_consistency.return_value = 'created_user'

        result1 = lambda_handler.check_roles_exist_and_create_if_not(
            both_roles_exist,
            mocked_user_dict,
            variables['assume_role_policy_json']
        )
        mock_create_role_and_await_consistency.assert_not_called()
        assert result1 == ['emrfs_user_one', 'emrfs_user_two']

        result2 = lambda_handler.check_roles_exist_and_create_if_not(
            one_role_does_not_exist,
            mocked_user_dict,
            variables['assume_role_policy_json']
        )

        mock_create_role_and_await_consistency.assert_called_once_with('emrfs_user_two', '{"json": "policy string"}')
        assert result2 == ['emrfs_user_one', 'created_user']

    @patch('aws_caller.get_policy_statement_as_list')
    def test_create_policy_object_list_from_policy_name_list(self, mock_get_policy_statement_as_list):
        mock_get_policy_statement_as_list.return_value = [{'test': 'statement'}]

        result = lambda_handler.create_policy_object_list_from_policy_name_list(
            ['policy_one', 'policy_three'],
            mocked_all_policy_list
        )

        assert result[0].get('policy_name') == 'policy_one'
        assert result[1].get('policy_name') == 'policy_three'
        assert result[0].get('statement') == [{'test': 'statement'}]

    @patch('lambda_handler.char_limit_of_json_policy', 70)
    def test_chunk_policies_and_return_dict_of_policy_name_to_json_CHUNKED(self):
        result = lambda_handler.chunk_policies_and_return_dict_of_policy_name_to_json(
            mocked_policy_object_list,
            'user_one',
            'emrfs_user_one'
        )

        assert result.get('emrfs_user_one-1of2') == {"Version": "2012-10-17", "Statement": [{'test': 'statement1'}]}
        assert result.get('emrfs_user_one-2of2') == {"Version": "2012-10-17", "Statement": [{'test': 'statement2'}]}

    @patch('lambda_handler.char_limit_of_json_policy', 100)
    def test_chunk_policies_and_return_dict_of_policy_name_to_json_NO_CHUNKS(self):
        result = lambda_handler.chunk_policies_and_return_dict_of_policy_name_to_json(
            mocked_policy_object_list,
            'user_one',
            'emrfs_user_one'
        )

        assert result.get('emrfs_user_one-1of1') == {
            "Version": "2012-10-17",
            "Statement": [{'test': 'statement1'}, {'test': 'statement2'}]
        }

    @patch('aws_caller.remove_policy_being_replaced')
    def test_remove_existing_user_policies(self, mock_remove_policy_being_replaced):
        calls = [
            call('arn:iam:123432/Policy/emrfs_test1', 'emrfs_user_one'),
            call('arn:iam:123432/Policy/emrfs_test2', 'emrfs_user_one')
        ]
        lambda_handler.remove_existing_user_policies('emrfs_user_no_policies', mocked_all_policy_list)

        mock_remove_policy_being_replaced.assert_not_called()

        lambda_handler.remove_existing_user_policies('emrfs_user_one', mocked_all_policy_list)

        mock_remove_policy_being_replaced.assert_has_calls(calls, any_order=True)

    @patch('aws_caller.get_all_role_tags')
    @patch('aws_caller.delete_role_tags')
    def test_delete_tags(self, mock_delete_role_tags, mock_get_all_role_tags):
        mock_get_all_role_tags.return_value = mocked_role_tags_response

        lambda_handler.delete_tags('emrfs_user_one')

        mock_get_all_role_tags.assert_called_once()
        mock_delete_role_tags.assert_called_with(['InputPolicies-1of20', 'InputPolicies-18of20'], 'emrfs_user_one')

    @patch('aws_caller.tag_role')
    def test_tag_role_with_policies_NOT_CHUNKED(self, mock_tag_role):
        lambda_handler.tag_role_with_policies(['policy_one', 'policy_two'], 'emrfs_user_one', variables['common_tags'])

        mock_tag_role.assert_called_with('emrfs_user_one', [
            {
                'Key': 'tag1key',
                'Value': 'tag1val'
            },
            {
                'Key': 'tag2key',
                'Value': 'tag2val'
            },
            {
                'Key': 'InputPolicies-1of1',
                'Value': 'policy_one/policy_two'
            },
        ])

    @patch('lambda_handler.char_limit_for_tag_value', 20)
    @patch('aws_caller.tag_role')
    def test_tag_role_with_policies_CHUNKED(self, mock_tag_role):
        lambda_handler.tag_role_with_policies(['policy_one', 'policy_two'], 'emrfs_user_one', variables['common_tags'])

        mock_tag_role.assert_called_with(
            'emrfs_user_one', [
                {'Key': 'tag1key', 'Value': 'tag1val'},
                {'Key': 'tag2key', 'Value': 'tag2val'},
                {'Key': 'InputPolicies-1of2', 'Value': 'policy_one'},
                {'Key': 'InputPolicies-2of2', 'Value': 'policy_two'},
            ]
        )

    def test_verify_policies_raises_error_on_missing_existing_policy(self):
        with self.assertRaises(NameError):
            lambda_handler.verify_policies(['policy_two'], mocked_policy_object_list)

    def test_verify_policies_does_not_raise_error_when_all_policies_found(self):
        self.assertIsNone(lambda_handler.verify_policies(['policy_one', 'policy_three'], mocked_policy_object_list))

    def test_verify_policies_does_not_raise_error_when_additional_policy_found_in_rds(self):
        self.assertIsNone(lambda_handler.verify_policies(['policy_one'], mocked_policy_object_list))

    def test_create_policy_document_from_template(self):
        result = lambda_handler.create_policy_document_from_template('test_user', ['group_one', 'group_two'], variables)
        assert result[0] == mock_statement_one
        assert result[1] == mock_statement_two
        assert result[2] == mock_statement_three

    @patch('aws_caller.create_cognito_client')
    @patch('aws_caller.get_groups_for_user')
    def test_update_user_groups_from_cognito(self, mock_get_groups_for_user, mock_create_cognito_client):
        mock_get_groups_for_user.side_effect = [['group_one', 'group_two'], ['group_two']]
        result = copy.deepcopy(mocked_user_dict_without_groups)
        lambda_handler.update_user_groups_from_cognito(result)

        assert result == mocked_user_dict
