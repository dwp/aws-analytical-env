import lambda_handler
from unittest import TestCase
from mock import call, patch

variables = {}
variables['database_cluster_arn'] = 'arn:12345432::test_arn'
variables['database_name'] = 'test_db'
variables['secret_arn'] = 'arn:12345432::secret_test_arn'
variables['cognito_userpool_id'] = '1234abcd-e5'

mocked_db_response = {
    'numberOfRecordsUpdated': 0,
    'records': [
        [{'stringValue': 'user_one123'}, {'booleanValue': False}, {'stringValue': 'group_one'}],
        [{'stringValue': 'user_two654'}, {'booleanValue': True}, {'stringValue': 'group_one'}],
        [{'stringValue': 'user_one123'}, {'booleanValue': False}, {'stringValue': 'group_two'}],
    ]
}

mocked_rds_user_dict = {
    'user_one': {
        'active': False,
        'group_names': ['group_one', 'group_two'],
        'user_name_sub': 'user_one123'
    },
    'user_two': {
        'active': True,
        'group_names': ['group_one'],
        'user_name_sub': 'user_two654'
    }
}

mocked_cognito_list_users_response =[{
        "Username": "user_one",
        "Attributes": [
            {
                "Name": "sub",
                "Value": "12345678976543212345678"
            }
        ],
        "UserCreateDate": 12345,
        "UserLastModifiedDate": 23456,
        "Enabled": True,
        "UserStatus": "SAMPLE_STATUS"
    },{
        "Username": "user_two",
        "Attributes": [
            {
                "Name": "sub",
                "Value": "654345676543234567765"
            }
        ],
        "UserCreateDate": 12345,
        "UserLastModifiedDate": 23456,
        "Enabled": False,
        "UserStatus": "SAMPLE_STATUS"
    },{
        "Username": "user_three",
        "Attributes": [
            {
                "Name": "sub",
                "Value": "876543234567876543234"
            }
        ],
        "UserCreateDate": 12345,
        "UserLastModifiedDate": 23456,
        "Enabled": True,
        "UserStatus": "SAMPLE_STATUS"
    }]

mocked_list_groups_for_user_response = [{
        "GroupName": "group_one",
        "UserPoolId": "1234567",
    },{
        "GroupName": "group_two",
        "UserPoolId": "1234567",
    }]

mocked_cognito_user_dict = {'user_one': {'active': True,
                                            'group_names': ['group_one', 'group_two'],
                                            'user_name_sub':'user_one123'},
                            'user_two': {'active': False,
                                            'group_names': ['group_one', 'group_two'],
                                            'user_name_sub':'user_two654'},
                            'user_three': {'active': True,
                                              'group_names': ['group_one', 'group_two'],
                                              'user_name_sub':'user_three876'}
                            }

# helper function to return true for assertion
class AnyArg(object):
    def __eq__(a, b):
        return True

class LambdaHandlerTests(TestCase):
    @patch('lambda_handler.os.getenv')
    def test_get_env_vars(self, mock_get_env):
        mock_get_env.side_effect = [variables['database_cluster_arn'],
                                    variables['database_name'],
                                    variables['secret_arn'],
                                    variables['cognito_userpool_id']]
        lambda_handler.get_env_vars()

        assert lambda_handler.variables['database_cluster_arn'] == variables['database_cluster_arn']
        assert lambda_handler.variables['database_name'] == variables['database_name']
        assert lambda_handler.variables['secret_arn'] == variables['secret_arn']
        assert lambda_handler.variables['cognito_userpool_id'] == variables['cognito_userpool_id']

    @patch('lambda_handler.execute_statement')
    def test_get_user_dict_from_rds(self, mock_execute_statement):
        mock_execute_statement.return_value = mocked_db_response
        result = lambda_handler.get_user_dict_from_rds(variables)
        assert result == mocked_rds_user_dict

    @patch('lambda_handler.get_users_in_userpool')
    @patch('lambda_handler.get_groups_for_user')
    def test_get_user_dict_from_cognito(self, mock_get_groups_for_user, mock_get_users_in_userpool):
        mock_get_users_in_userpool.return_value = mocked_cognito_list_users_response
        mock_get_groups_for_user.return_value = mocked_list_groups_for_user_response
        result = lambda_handler.get_user_dict_from_cognito(variables['cognito_userpool_id'])

        assert result == mocked_cognito_user_dict

    @patch('lambda_handler.execute_statement')
    def test_sync_values(self, mock_execute_statement):
        lambda_handler.sync_values(mocked_cognito_user_dict, mocked_rds_user_dict, variables)

        name, args, kwargs = mock_execute_statement.mock_calls[0]
        assert 'UPDATE Users SET active = True WHERE userName = user_one; UPDATE Users SET active = False WHERE userName = user_two; INSERT INTO User (userName, active) VALUES (user_three, True)' in args[0]
        mock_execute_statement.assert_called_with(
            AnyArg(),
            variables['secret_arn'],
            variables["database_name"],
            variables["database_cluster_arn"]
        )
