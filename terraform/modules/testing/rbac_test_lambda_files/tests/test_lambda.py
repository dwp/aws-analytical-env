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
class TestDataAccess(TestCase):
    def test_access_denied_returned(self, mock_get):
        print("\nStart check access denied message returned\n")

        table = {"name": "test_table_pii", "type": "pii"}
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
        mock_get.side_effect = mock_response
        response = rbac_lambda.make_api_call(sessions_url, table)
        assert "Service: Amazon S3; Status Code: 403; Error Code: AccessDenied" in response["output"]["evalue"]

    def test_check_for_access_granted_to_data_as_non_pii(self, mock_check):
        print("\nStart check for access granted\n")

        table = {"name": "test_table_pii", "type": "non_pii"}
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
                body=b'{"id":0,"proxyUser":"testuser017","state":"available","kind":"spark","output":{"status":"ok","data":"Data"}}'
            ),
            urllib3.response.HTTPResponse(
                body=b'"SessionKilled'
            )
        ]
        mock_check.side_effect = mock_response
        response = rbac_lambda.make_api_call(sessions_url, table)
        assert "Data" in response["output"]["data"]
