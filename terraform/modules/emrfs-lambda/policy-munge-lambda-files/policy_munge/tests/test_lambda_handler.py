import copy
import json
from unittest import TestCase

from mock import call, patch, MagicMock

import lambda_handler
from util import str_md5_digest

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
variables['s3fs_kms_arn'] = 'arn:aws:kms:eu-west-7:1234567:key/master-12ab-34cd-56ef-1234567890ab'

mocked_db_response = {
    'numberOfRecordsUpdated': 0,
    'records': [
        [{'stringValue': 'user_one'}, {'booleanValue': False}, {'stringValue': 'policy_one'},
         {'stringValue': 'group_one'}],
        [{'stringValue': 'user_two'}, {'booleanValue': True}, {'stringValue': 'policy_one'},
         {'stringValue': 'group_two'}],
        [{'stringValue': 'user_one'}, {'booleanValue': False}, {'stringValue': 'policy_two'},
         {'stringValue': 'group_two'}],
    ]
}

mocked_user_dict = {
    'user_one': {
        'active': False,
        'policy_names': ['emrfs_iam', 'policy_one', 'policy_two'],
        'role_name': 'emrfs_user_one',
    },
    'user_two': {
        'active': True,
        'policy_names': ['emrfs_iam', 'policy_one'],
        'role_name': 'emrfs_user_two',
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

mock_statement_one = {
    "Sid": "s3fsaccessdocument",
    "Effect": "Allow",
    "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:PutObjectAcl",
        "s3:GetObjectVersion",
        "s3:DeleteObject"
    ],
    "Resource": [
        "arn:12345432::s3_test_arn/home/test_user/*",
    ]
}

mock_statement_two = {
    "Sid": "s3fskmsaccessdocument",
    "Effect": "Allow",
    "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:DescribeKey",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*"
    ],
    "Resource": [
        "arn:aws:kms:eu-west-7:1234567:key/master-12ab-34cd-56ef-1234567890ab",
        "arn:aws:kms:eu-west-7:1234567:key/testuser-12ab-34cd-56ef-1234567890ab"
    ]
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

    @patch('lambda_handler.aws_caller.execute_statement')
    def test_get_user_userstatus_policy_dict(self, mock_execute_statement):
        mock_execute_statement.side_effect = [mocked_db_response, {'numberOfRecordsUpdated': 0, 'records': []}]
        result1 = lambda_handler.get_db_user_info()
        assert result1 == mocked_user_dict

        self.assertRaises(
            ValueError,
            lambda_handler.get_db_user_info
        )

    @patch('lambda_handler.aws_caller.create_role_and_await_consistency')
    def test_check_roles_exist_and_create_if_not(self, mock_create_role_and_await_consistency):
        one_role_does_not_exist = ['emrfs_user_one']
        both_roles_exist = ['emrfs_user_one', 'emrfs_user_two']
        mock_create_role_and_await_consistency.return_value = 'created_user'

        result1 = lambda_handler.ensure_roles(
            both_roles_exist,
            mocked_user_dict,
            variables['assume_role_policy_json']
        )
        mock_create_role_and_await_consistency.assert_not_called()
        assert result1 == ['emrfs_user_one', 'emrfs_user_two']

        result2 = lambda_handler.ensure_roles(
            one_role_does_not_exist,
            mocked_user_dict,
            variables['assume_role_policy_json']
        )

        mock_create_role_and_await_consistency.assert_called_once_with('emrfs_user_two', '{"json": "policy string"}')
        assert result2 == ['emrfs_user_one', 'created_user']

    @patch('lambda_handler.aws_caller.get_policy_statements')
    def test_create_policy_object_list_from_policy_name_list(self, mock_get_policy_statements):
        mock_get_policy_statements.return_value = [{'test': 'statement'}]

        result = lambda_handler.get_policy_info(
            ['policy_one', 'policy_three'],
            mocked_all_policy_list
        )

        assert result[0].get('policy_name') == 'policy_one'
        assert result[1].get('policy_name') == 'policy_three'
        assert result[0].get('statement') == [{'test': 'statement'}]

    @patch('lambda_handler.CHAR_LIMIT_JSON_POLICY', 70)
    def test_chunk_policies_and_return_dict_of_policy_name_to_json_CHUNKED(self):
        result = lambda_handler.chunk_policies_and_return_dict_of_policy_name_to_json(
            mocked_policy_object_list,
            'user_one',
            'emrfs_user_one'
        )

        assert result.get('emrfs_user_one-1of2') == {"Version": "2012-10-17", "Statement": [{'test': 'statement1'}]}
        assert result.get('emrfs_user_one-2of2') == {"Version": "2012-10-17", "Statement": [{'test': 'statement2'}]}

    @patch('lambda_handler.CHAR_LIMIT_JSON_POLICY', 100)
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

    @patch('lambda_handler.aws_caller.remove_policy_being_replaced')
    def test_remove_existing_user_policies(self, mock_remove_policy_being_replaced):
        calls = [
            call('arn:iam:123432/Policy/emrfs_test1', 'emrfs_user_one'),
            call('arn:iam:123432/Policy/emrfs_test2', 'emrfs_user_one')
        ]
        lambda_handler.remove_existing_user_policies('emrfs_user_no_policies', mocked_all_policy_list)

        mock_remove_policy_being_replaced.assert_not_called()

        lambda_handler.remove_existing_user_policies('emrfs_user_one', mocked_all_policy_list)

        mock_remove_policy_being_replaced.assert_has_calls(calls, any_order=True)

    @patch('lambda_handler.aws_caller.get_all_role_tags')
    @patch('lambda_handler.aws_caller.delete_role_tags')
    def test_delete_tags(self, mock_delete_role_tags, mock_get_all_role_tags):
        mock_get_all_role_tags.return_value = mocked_role_tags_response

        lambda_handler.delete_tags('emrfs_user_one')

        mock_get_all_role_tags.assert_called_once()
        mock_delete_role_tags.assert_called_with(['InputPolicies-1of20', 'InputPolicies-18of20'], 'emrfs_user_one')

    @patch('lambda_handler.aws_caller.tag_role')
    def test_tag_role_with_policies_NOT_CHUNKED(self, mock_tag_role: MagicMock):
        lambda_handler.tag_role_with_policies(['policy_one', 'policy_two'], 'emrfs_user_one', variables['common_tags'])
        mock_tag_role.assert_called()
        args = mock_tag_role.call_args.args
        assert args[0] == 'emrfs_user_one'
        self.assertCountEqual(args[1], [
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

    @patch('lambda_handler.CHAR_LIMIT_TAG_VALUE', 20)
    @patch('lambda_handler.aws_caller.tag_role')
    def test_tag_role_with_policies_CHUNKED(self, mock_tag_role: MagicMock):
        lambda_handler.tag_role_with_policies(['policy_one', 'policy_two'], 'emrfs_user_one', variables['common_tags'])
        mock_tag_role.assert_called()
        args = mock_tag_role.call_args.args
        assert args[0] == 'emrfs_user_one'
        self.assertCountEqual(args[1], [
            {'Key': 'tag1key', 'Value': 'tag1val'},
            {'Key': 'tag2key', 'Value': 'tag2val'},
            {'Key': 'InputPolicies-1of2', 'Value': 'policy_one'},
            {'Key': 'InputPolicies-2of2', 'Value': 'policy_two'},
        ])

    @patch('lambda_handler.aws_caller.get_kms_arn')
    def test_create_policy_document_from_template(self, mock_get_kms_arn):
        mock_get_kms_arn.side_effect = [
            "arn:aws:kms:eu-west-7:1234567:key/testuser-12ab-34cd-56ef-1234567890ab"
        ]
        result = lambda_handler.create_policy_document_from_template('test_user', variables['s3fs_bucket_arn'],
                                                                     variables['s3fs_kms_arn'])
        assert result[0] == mock_statement_one
        assert result[1] == mock_statement_two
        assert result[2] == mock_statement_three

    def test_prevent_matching_sids(self):
        duplicate_sid = copy.deepcopy(iam_template)
        duplicate_sid["Statement"] = [
            copy.deepcopy(mock_statement_one),
            copy.deepcopy(mock_statement_two),
            copy.deepcopy(mock_statement_two),
            copy.deepcopy(mock_statement_one),
            copy.deepcopy(mock_statement_three),
            copy.deepcopy(mock_statement_one)
        ]
        lambda_handler.prevent_matching_sids(duplicate_sid["Statement"])
        sids_in_processed_json = [statement_object["Sid"] for statement_object in duplicate_sid["Statement"]]
        assert sids_in_processed_json == [
            's3fsaccessdocument',
            's3fskmsaccessdocument',
            's3fskmsaccessdocument1',
            's3fsaccessdocument1',
            's3fslist',
            's3fsaccessdocument2'
        ]

    @patch('lambda_handler.aws_caller.get_kms_arn')
    def test_handle_group_kms_not_found_issues(self, mock_get_kms_arn):
        mock_get_kms_arn.side_effect = [None]
        missing_user_key = lambda_handler.create_policy_document_from_template('test_user',
                                                                               variables['s3fs_bucket_arn'],
                                                                               variables['s3fs_kms_arn'])

        assert missing_user_key[0].get('Resource') == [
            'arn:12345432::s3_test_arn/home/test_user/*'
        ]
        assert missing_user_key[1].get('Resource') == [
            'arn:aws:kms:eu-west-7:1234567:key/master-12ab-34cd-56ef-1234567890ab'
        ]
        assert missing_user_key[2].get('Resource') == [
            "arn:12345432::s3_test_arn"
        ]

    @patch('lambda_handler.aws_caller.get_all_role_tags')
    def test_role_needs_update_no_hash(self, mock_get_role_tags: MagicMock):
        mock_get_role_tags.return_value = {'Tags': [
            {'Key': 'UnusedKey', 'Value': 'UnusedValue'}
        ]}

        assert lambda_handler.role_needs_update("RoleName", '[{"Sid":"test_sid"}]') is True

    @patch('lambda_handler.aws_caller.get_all_role_tags')
    def test_role_needs_update_changed(self, mock_get_role_tags: MagicMock):
        old_policy = json.dumps([{"Sid": "test_sid"}])
        mock_get_role_tags.return_value = {'Tags': [
            {'Key': 'AttachedPoliciesHash', 'Value': str_md5_digest(old_policy)}
        ]}

        new_policy = json.dumps([{"Sid": "test_sid", "Effect": "Allow"}])
        assert lambda_handler.role_needs_update("RoleName", new_policy) is True

    @patch('lambda_handler.aws_caller.get_all_role_tags')
    def test_role_needs_update_not_changed(self, mock_get_role_tags: MagicMock):
        policy = json.dumps([{"Sid": "test_sid"}])
        mock_get_role_tags.return_value = {'Tags': [
            {'Key': 'AttachedPoliciesHash', 'Value': str_md5_digest(policy)}
        ]}

        assert lambda_handler.role_needs_update("RoleName", policy) is False
