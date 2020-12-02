import aws_caller
from unittest import TestCase
from mock import patch, Mock

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
        {'Key': 'InputPolicies-1of2','Value': 'policy_one'}
    ],
    'IsTruncated': True,
    'Marker': 'string'
}

tags_not_truncated = {
    'Tags': [
        {'Key': 'tag3key', 'Value': 'tag3val'},
        {'Key': 'tag4key', 'Value': 'tag4val'},
        {'Key': 'InputPolicies-2of2','Value': 'policy_two'}
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

class AwsCallerTests(TestCase):

    @patch('aws_caller.iam_client.list_policies')
    def test_list_all_policies_in_account(self, mock_list_policies):
        mock_list_policies.side_effect = [policies_truncated, policies_truncated, policies_not_truncated]
        result = aws_caller.list_all_policies_in_account()

        assert result == policies_truncated['Policies'] + policies_truncated['Policies'] + policies_not_truncated['Policies']

    @patch('aws_caller.iam_client.list_role_tags')
    def test_get_all_role_tags(self, mock_list_role_tags):
        mock_list_role_tags.side_effect = [tags_truncated, tags_truncated, tags_not_truncated]
        result = aws_caller.get_all_role_tags('emrfs_user_one')

        assert result == tags_truncated['Tags'] + tags_truncated['Tags'] + tags_not_truncated['Tags']

    @patch('aws_caller.iam_client.list_roles')
    def test_get_emrfs_roles(self, mock_list_role_tags):
        mock_list_role_tags.side_effect = [roles_truncated, roles_truncated, roles_not_truncated]
        result = aws_caller.get_emrfs_roles()

        assert result == ['emrfs_user_one', 'emrfs_user_two', 'emrfs_user_three', 'emrfs_user_one', 'emrfs_user_two', 'emrfs_user_three', 'emrfs_user_four', 'emrfs_user_five', 'emrfs_user_six']
