from unittest import TestCase
from unittest.mock import Mock, patch
import rbac_lambda
import json
import urllib3

host = "http://test_host.com:8998"
sessions_url = host + "/sessions"
proxy_user = "test_user"
non_pii_table_name = "test_non_pii_table"
pii_table_name = "test_pii_table"
database_name = "test_database"


@patch('rbac_lambda.urllib3.PoolManager.request')
class TestRbac(TestCase):
    # Expected: One request, creates session and returns session url
    def test_inital_request(self, mock_post):
        print("\nStart test_initial_request\n")

        code = {
            'kind': 'spark',
            'proxyUser': 'test_user'
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

    # Excepted: 403
    # Actual : 403
    def test_check_for_access_denied(self, mock_check):
        print("\nStart test_check_403_returned\n")
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
        ]
        mock_check.side_effect = mock_response
        expected = "OK"
        actual = rbac_lambda.check_for_access_denied(sessions_url, pii_table_name)
        assert expected == actual


    # Excepted: 403
    # Actual : Not 403
    def test_check_for_access_not_denied(self, mock_check):
        print("\nStart test_check_when_403_isnt_returned\n")
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
        with self.assertRaises(SystemExit):
            rbac_lambda.check_for_access_denied(sessions_url, pii_table_name)

    # Expected: 200
    # Actual : 200
    def test_check_for_access_granted(self, mock_check):
        print("\nStart test_check_when_403_isnt_returned\n")
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
        actual = rbac_lambda.check_for_access_granted(sessions_url, non_pii_table_name)
        expected = "OK"
        assert expected == actual

    # Excepted: 200
    # Actual : 403
    def test_check_for_access_granted_error(self, mock_check):
        print("\nStart test_check_403_returned\n")
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
        with self.assertRaises(SystemExit):
            rbac_lambda.check_for_access_granted(sessions_url, non_pii_table_name)
