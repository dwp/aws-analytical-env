from unittest import TestCase
from unittest.mock import Mock, patch
import rbac_lambda
import json
import urllib3

host = "http://test_host.com:8998"
sessions_url = host + "/sessions"
proxy_user = "test_user"
database_name = "test_database"

@patch('rbac_lambda.urllib3.PoolManager.request')
class TestSessionSetup(TestCase):
    # Expected: One request, creates session and returns session url
    def test_inital_request(self, mock_post):
        print("\nStart test_initial_request\n")

        code = {
            'kind': 'spark',
            'proxyUser': proxy_user
        }
        mock_response = urllib3.response.HTTPResponse(
            body=b'{"id":0,"proxyUser":"testuser017","state":"starting","kind":"spark"}',
            status=200,
            headers={
                "location": "/sessions/1"
            }
        )

        mock_post.return_value = mock_response
        response = rbac_lambda.initial_request(sessions_url, code)
        assert response == (host + mock_response.headers["location"])

    # Expected: 3 iterations of loop, then response once state=idle
    def test_poll_for_result(self, mock_get):
        print("\nStart test_poll_for_result\n")

        status_url = host + "/sessions/1"
        mock_response = [
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"starting","kind":"spark"}',
            ),
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"starting","kind":"spark"}',
            ),
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"idle","kind":"spark"}',
            )
        ]
        mock_get.side_effect = mock_response
        response = rbac_lambda.poll_for_result(sessions_url, status_url)
        assert response["state"] == "idle"
        assert mock_get.call_count == 3


@patch('rbac_lambda.urllib3.PoolManager.request')
class TestNonPiiTable(TestCase):
    # Expected: 200
    # Actual : 200
    def test_check_for_access_granted_to_non_pii_as_non_pii(self, mock_check):
        print("\nStart test access granted to non-PII table as non-PII user\n")

        access = "non_pii"
        table = {"name": "test_table_non_pii", "type": "non_pii"}

        mock_response = [
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"starting","kind":"spark"}',
                status=200,
                headers={
                    "location": "/sessions/1/statements/1"
                }
            ),
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"waiting","kind":"spark"}',
            ),
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"available","kind":"spark","output":{"status":"ok","evalue":"Data"}}'
            ),
            urllib3.response.HTTPResponse(
                body=b'"SessionKilled'
            )
        ]
        mock_check.side_effect = mock_response
        actual = rbac_lambda.check_access_is_correct(sessions_url, table, access)
        expected = "OK"
        assert expected == actual

    # Excepted: 200
    # Actual : 200
    def test_check_for_access_granted_to_non_pii_as_pii_user(self, mock_check):
        print("\nStart test access granted to non-PII table as PII user\n")

        access = "pii"
        table = {"name": "test_table_non_pii", "type": "non_pii"}

        mock_response = [
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"starting","kind":"spark"}',
                status=200,
                headers={
                    "location": "/sessions/1/statements/1"
                }
            ),
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"waiting","kind":"spark"}',
            ),
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"available","kind":"spark","output":{"status":"ok","evalue":"Data"}}'
            ),
            urllib3.response.HTTPResponse(
                body=b'"SessionKilled'
            )
        ]
        mock_check.side_effect = mock_response
        actual = rbac_lambda.check_access_is_correct(sessions_url, table, access)
        expected = "OK"
        assert expected == actual


@patch('rbac_lambda.urllib3.PoolManager.request')
class TestPiiTable(TestCase):
    # Expected 403
    # Actual 200
    def test_check_for_access_denied_to_pii_as_non_pii_user(self, mock_check):
        print("\nStart check for access denied to PII table as non-PII user\n")

        table = {"name": "test_table_pii", "type": "pii"}
        access = "non_pii"

        mock_response = [
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"starting","kind":"spark"}',
                status=200,
                headers={
                    "location": "/sessions/1/statements/1"
                }
            ),
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"waiting","kind":"spark"}',
            ),
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"available","kind":"spark","output":{"status":"error","evalue":"Service: Amazon S3; Status Code: 403; Error Code: AccessDenied"}}'
            ),
            urllib3.response.HTTPResponse(
                body=b'"SessionKilled'
            )
        ]
        mock_check.side_effect = mock_response
        expected = "OK"
        actual = rbac_lambda.check_access_is_correct(sessions_url, table, access)
        assert expected == actual

    # Excepted: 200
    # Actual : 200
    def test_check_for_access_granted_to_pii_as_pii(self, mock_check):
        print("\nStart check for access granted to PII table as PII user\n")

        table = {"name": "test_table_pii", "type": "pii"}
        access = "pii"

        mock_response = [
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"starting","kind":"spark"}',
                status=200,
                headers={
                    "location": "/sessions/1/statements/1"
                }
            ),
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"waiting","kind":"spark"}',
            ),
            urllib3.response.HTTPResponse(
                body=b'{"id":0,"proxyUser":"testuser017","state":"available","kind":"spark","output":{"status":"ok","evalue":"Data"}}'
            ),
            urllib3.response.HTTPResponse(
                body=b'"SessionKilled'
            )
        ]
        mock_check.side_effect = mock_response
        actual = rbac_lambda.check_access_is_correct(sessions_url, table, access)
        expected = "OK"
        assert expected == actual
