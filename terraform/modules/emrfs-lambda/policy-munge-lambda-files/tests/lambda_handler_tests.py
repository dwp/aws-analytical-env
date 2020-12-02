import lambda_handler
from unittest import TestCase
from mock import patch

variables = {}
variables['database_arn'] = 'arn:12345432::test_arn'
variables['database_name'] = 'test_db'
variables['secret_arn'] = 'arn:12345432::secret_test_arn'
variables['common_tags'] = {'tag1key': 'tag1val', 'tag2key': 'tag2val'}
variables['assume_role_policy_json'] = '{"json": "policy string"}'

mocked_db_response = {
    'numberOfRecordsUpdated': 0,
    'records': [
        [{'stringValue': 'user_one'}, {'booleanValue': False},{'stringValue': 'policy_one' }],
        [{'stringValue': 'user_two'}, {'booleanValue': True},{'stringValue': 'policy_one' }],
        [{'stringValue': 'user_one'}, {'booleanValue': False},{'stringValue': 'policy_two' }],
    ]
}

mocked_user_dict ={
    'user_one':{'active': False, 'policy_names': ['policy_one', 'policy_two'], 'role_name': 'emrfs_user_one'},
    'user_two': {'active': True, 'policy_names': ['policy_one'], 'role_name': 'emrfs_user_two'}
}

mocked_policy_object_array = [
    {'policy_name': 'policy_one', 'statement': [{'test': 'statement1'}], 'chars': 23, 'chunk_number': None},
    {'policy_name': 'policy_three', 'statement': [{'test': 'statement2'}], 'chars': 23, 'chunk_number': None}
]

iam_template = {"Version": "2012-10-17", "Statement": []}


class TestLambdaHandler(TestCase):

    @patch('lambda_handler.execute_statement')
    def test_get_user_userstatus_policy_dict(self, mock_execute_statement):
        mock_execute_statement.return_value = mocked_db_response
        response = lambda_handler.get_user_userstatus_policy_dict(variables)
        assert response == mocked_user_dict

    @patch('lambda_handler.create_role_and_await_consistency')
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

    @patch('lambda_handler.list_all_policies_in_account')
    @patch('lambda_handler.get_policy_statement_as_list')
    def test_create_policy_object_array_from_policy_name_array(self, mock_get_policy_statement_as_list, mock_list_all_policies_in_account):
        policy_list=[
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
            }
        ]
        mock_list_all_policies_in_account.return_value = policy_list
        mock_get_policy_statement_as_list.return_value = [{'test': 'statement'}]

        result = lambda_handler.create_policy_object_array_from_policy_name_array(['policy_one', 'policy_three'])
        assert result[0].get('policy_name') == 'policy_one'
        assert result[1].get('policy_name') == 'policy_three'
        assert result[0].get('statement') == [{'test': 'statement'}]


    @patch('lambda_handler.char_limit_of_json_policy', 70)
    def test_chunk_policies_and_return_dict_of_policy_name_to_json_CHUNKED(self):
        result = lambda_handler.chunk_policies_and_return_dict_of_policy_name_to_json(
            mocked_policy_object_array,
            'user_one',
            'emrfs_user_one'
        )
        assert result.get('user_one-1of2') == {"Version": "2012-10-17", "Statement": [{'test': 'statement1'}]}
        assert result.get('user_one-2of2') == {"Version": "2012-10-17", "Statement": [{'test': 'statement2'}]}


    @patch('lambda_handler.char_limit_of_json_policy', 100)
    def test_chunk_policies_and_return_dict_of_policy_name_to_json_NO_CHUNKS(self):
        result = lambda_handler.chunk_policies_and_return_dict_of_policy_name_to_json(
            mocked_policy_object_array,
            'user_one',
            'emrfs_user_one'
        )
        assert result.get('user_one-1of1') == {
            "Version": "2012-10-17",
            "Statement": [{'test': 'statement1'}, {'test': 'statement2'}]
        }




