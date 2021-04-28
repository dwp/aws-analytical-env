from unittest import TestCase

import botocore
from mock import call, patch

import aws_caller

policies_truncated = {
    'Policies': [
        {'PolicyName': 'policy_one', 'PolicyId': 'policy_one_id', 'Arn': 'arn:iam:123432/Policy/test1'},
        {'PolicyName': 'policy_two', 'PolicyId': 'policy_two_id', 'Arn': 'arn:iam:123432/Policy/test2'}
    ],
    'IsTruncated': True,
    'Marker': 'string'
}

policies_not_truncated = {
    'Policies': [
        {'PolicyName': 'policy_three', 'PolicyId': 'policy_three_id', 'Arn': 'arn:iam:123432/Policy/test3'},
        {'PolicyName': 'policy_four', 'PolicyId': 'policy_four_id', 'Arn': 'arn:iam:123432/Policy/test4'}
    ],
    'IsTruncated': False,
}

tags_truncated = {
    'Tags': [
        {'Key': 'tag1key', 'Value': 'tag1val'},
        {'Key': 'tag2key', 'Value': 'tag2val'},
        {'Key': 'InputPolicies-1of2', 'Value': 'policy_one'}
    ],
    'IsTruncated': True,
    'Marker': 'string'
}

tags_not_truncated = {
    'Tags': [
        {'Key': 'tag3key', 'Value': 'tag3val'},
        {'Key': 'tag4key', 'Value': 'tag4val'},
        {'Key': 'InputPolicies-2of2', 'Value': 'policy_two'}
    ],
    'IsTruncated': False,
}

roles_truncated = {
    'Roles': [
        {'RoleName': 'emrfs_user_one'},
        {'RoleName': 'emrfs_user_two'},
        {'RoleName': 'emrfs_user_three'},
    ],
    'IsTruncated': True,
    'Marker': 'string'
}

roles_not_truncated = {
    'Roles': [
        {'RoleName': 'emrfs_user_four'},
        {'RoleName': 'emrfs_user_five'},
        {'RoleName': 'emrfs_user_six'},
    ],
    'IsTruncated': False,
}

kms_found_response = {
    'KeyMetadata': {
        'AWSAccountId': '111122223333',
        'Arn': 'arn:aws:kms:us-east-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab',
        'CreationDate': "test_date",
        'Description': '',
        'Enabled': True,
        'KeyId': '1234abcd-12ab-34cd-56ef-1234567890ab',
        'KeyManager': 'CUSTOMER',
        'KeyState': 'Enabled',
        'KeyUsage': 'ENCRYPT_DECRYPT',
        'Origin': 'AWS_KMS',
    },
    'ResponseMetadata': {
        '...': '...',
    },
}

mock_list_policy_versions_response = {
    'Versions': [
        {
            'Document': 'string',
            'VersionId': 'non_default_1',
            'IsDefaultVersion': False,
            'CreateDate': ""
        },
        {
            'Document': 'string',
            'VersionId': 'non_default_2',
            'IsDefaultVersion': False,
            'CreateDate': ""
        },
        {
            'Document': 'string',
            'VersionId': 'default',
            'IsDefaultVersion': True,
            'CreateDate': ""
        },
        {
            'Document': 'string',
            'VersionId': 'non_default_3',
            'IsDefaultVersion': False,
            'CreateDate': ""
        },
    ]
}


class AwsCallerTests(TestCase):

    @patch('aws_caller.iam_client.list_policies')
    def test_list_all_policies_in_account(self, mock_list_policies):
        mock_list_policies.side_effect = [policies_truncated, policies_truncated, policies_not_truncated]
        result = aws_caller.list_all_policies_in_account()

        assert result == policies_truncated['Policies'] + policies_truncated['Policies'] + policies_not_truncated[
            'Policies']

    @patch('aws_caller.iam_client.list_role_tags')
    def test_get_all_role_tags(self, mock_list_role_tags):
        mock_list_role_tags.side_effect = [tags_truncated, tags_truncated, tags_not_truncated]
        result = aws_caller.get_all_role_tags('emrfs_user_one')

        assert result == tags_truncated['Tags'] + tags_truncated['Tags'] + tags_not_truncated['Tags']

    @patch('aws_caller.iam_client.list_roles')
    def test_get_emrfs_roles(self, mock_list_role_tags):
        mock_list_role_tags.side_effect = [roles_truncated, roles_truncated, roles_not_truncated]
        result = aws_caller.get_emrfs_roles()

        assert result == ['emrfs_user_one', 'emrfs_user_two', 'emrfs_user_three', 'emrfs_user_one', 'emrfs_user_two',
                          'emrfs_user_three', 'emrfs_user_four', 'emrfs_user_five', 'emrfs_user_six']

    @patch('aws_caller.kms_client.describe_key')
    def test_get_kms_arn_found_kms(self, mock_describe_key):
        mock_describe_key.return_value = kms_found_response
        assert aws_caller.get_kms_arn(
            "/alias/test") == 'arn:aws:kms:us-east-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab'

    @patch('aws_caller.kms_client.describe_key')
    def test_get_kms_arn_not_found_kms(self, mock_describe_key):
        mock_describe_key.side_effect = botocore.exceptions.ClientError({'Error': {'Code': 'NotFoundException'}}, 'KMS')
        assert aws_caller.get_kms_arn("/alias/test") == None

    @patch('aws_caller.iam_client.list_policy_versions')
    @patch('aws_caller.iam_client.delete_policy')
    @patch('aws_caller.iam_client.detach_role_policy')
    def test_handling_of_detach_role_policy_correct_error(self, mock_detach_role_policy, mock_delete_policy,
                                                          mock_list_policy_versions):
        mock_detach_role_policy.side_effect = botocore.exceptions.ClientError({'Error': {'Code': 'NoSuchEntity'}},
                                                                              'IAM')

        try:
            aws_caller.remove_policy_being_replaced('arn:aws:iam::111122223333:policy/test_policy', 'test_role')
        except botocore.exceptions.ClientError:
            self.fail('error was not handled in function')

    @patch('aws_caller.iam_client.list_policy_versions')
    @patch('aws_caller.iam_client.delete_policy')
    @patch('aws_caller.iam_client.detach_role_policy')
    def test_handling_of_detach_role_policy_other_error(self, mock_detach_role_policy, mock_delete_policy,
                                                        mock_list_policy_versions):
        mock_detach_role_policy.side_effect = botocore.exceptions.ClientError({'Error': {'Code': 'OtherError'}}, 'IAM')

        try:
            aws_caller.remove_policy_being_replaced('arn:aws:iam::111122223333:policy/test_policy', 'test_role')
        except botocore.exceptions.ClientError as e:
            print(f'Passed as raised error: {e}')

    @patch('aws_caller.iam_client.delete_policy')
    @patch('aws_caller.iam_client.delete_policy_version')
    @patch('aws_caller.iam_client.list_policy_versions')
    @patch('aws_caller.iam_client.detach_role_policy')
    def test_policy_version_deletion_logic(self, mock_detach_role_policy, mock_list_policy_versions,
                                           mock_delete_policy_version, mock_delete_policy):
        mock_list_policy_versions.return_value = mock_list_policy_versions_response
        calls = [
            call(PolicyArn='test_arn', VersionId='non_default_1'),
            call(PolicyArn='test_arn', VersionId='non_default_2'),
            call(PolicyArn='test_arn', VersionId='non_default_3')
        ]

        aws_caller.remove_policy_being_replaced('test_arn', 'test_role')
        mock_delete_policy_version.assert_has_calls(calls, any_order=True)
        mock_delete_policy.assert_called_once_with(PolicyArn='test_arn')
