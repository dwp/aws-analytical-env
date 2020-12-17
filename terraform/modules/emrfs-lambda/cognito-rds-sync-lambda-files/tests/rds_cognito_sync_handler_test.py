import lambda_handler
from unittest import TestCase
from mock import call, patch

variables = {}
variables['database_cluster_arn'] = 'arn:12345432::test_arn'
variables['database_name'] = 'test_db'
variables['secret_arn'] = 'arn:12345432::secret_test_arn'
variables['cognito_userpool_id'] = '1234abcd-e5'
variables['mgmt_account_role_arn'] = 'arn:12345432::mgmt_role_arn'

mocked_db_response = {
    'numberOfRecordsUpdated': 0,
    'records': [
        [{'stringValue': 'user_one123'}, {'booleanValue': False}],
        [{'stringValue': 'user_two654'}, {'booleanValue': True}],
        [{'stringValue': 'user_one123'}, {'booleanValue': False}],
        [{'stringValue': 'user_four987'}, {'booleanValue': True}],
    ]
}

mocked_rds_user_dict = {
    'user_one': {
        'active': False,
        'user_name_sub': 'user_one123'
    },
    'user_two': {
        'active': True,
        'user_name_sub': 'user_two654'
    },
    'user_four': {
        'active': True,
        'user_name_sub': 'user_four987'
    }
}

mocked_cognito_list_users_response = [{
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
}, {
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
}, {
    "Username": "account_name_only",
    "Attributes": [
        {
            "Name": "sub",
            "Value": "876543234567876543234"
        },
        {
            "Name": "preferred_username",
            "Value": "user_three"
        }
    ],
    "UserCreateDate": 12345,
    "UserLastModifiedDate": 23456,
    "Enabled": True,
    "UserStatus": "SAMPLE_STATUS"
}]

mocked_cognito_user_dict = {'user_one': {'active': True,
                                         'user_name_sub': 'user_one123',
                                         'account_name': 'user_one'
                                         },
                            'user_two': {'active': False,
                                         'user_name_sub': 'user_two654',
                                         'account_name': 'user_two'
                                         },
                            'user_three': {'active': True,
                                           'user_name_sub': 'user_three876',
                                           'account_name': 'account_name_only'
                                           }
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
                                    variables['cognito_userpool_id'],
                                    variables['mgmt_account_role_arn']]
        lambda_handler.get_env_vars()

        assert lambda_handler.variables['database_cluster_arn'] == variables['database_cluster_arn']
        assert lambda_handler.variables['database_name'] == variables['database_name']
        assert lambda_handler.variables['secret_arn'] == variables['secret_arn']
        assert lambda_handler.variables['cognito_userpool_id'] == variables['cognito_userpool_id']
        assert lambda_handler.variables['mgmt_account_role_arn'] == variables['mgmt_account_role_arn']

    @patch('lambda_handler.execute_statement')
    def test_get_user_dict_from_rds(self, mock_execute_statement):
        mock_execute_statement.return_value = mocked_db_response
        result = lambda_handler.get_user_dict_from_rds(variables)
        assert result == mocked_rds_user_dict

    @patch('lambda_handler.get_users_in_userpool')
    def test_get_user_dict_from_cognito(self, mock_get_users_in_userpool):
        mock_get_users_in_userpool.return_value = mocked_cognito_list_users_response
        result = lambda_handler.get_user_dict_from_cognito(variables['cognito_userpool_id'])

        assert result['user_three']['account_name'] == 'account_name_only'
        assert result == mocked_cognito_user_dict

    @patch('lambda_handler.execute_statement')
    def test_sync_values(self, mock_execute_statement):
        calls = [
            call(
                'UPDATE User SET active = 0 WHERE username = "user_four987";',
                variables['secret_arn'],
                variables["database_name"],
                variables["database_cluster_arn"]),
            call(
                'INSERT INTO User (username, active, accountname) VALUES ("user_three876", 1, "account_name_only");',
                variables['secret_arn'],
                variables["database_name"],
                variables["database_cluster_arn"]),
            call(
                'UPDATE User SET active = 0 WHERE username = "user_two654";',
                variables['secret_arn'],
                variables["database_name"],
                variables["database_cluster_arn"]),
            call(
                'UPDATE User SET active = 1 WHERE username = "user_one123";',
                variables['secret_arn'],
                variables["database_name"],
                variables["database_cluster_arn"])
        ]
        lambda_handler.sync_values(mocked_cognito_user_dict, mocked_rds_user_dict, variables)

        mock_execute_statement.assert_has_calls(calls, any_order=True)
        assert 4 == mock_execute_statement.call_count
