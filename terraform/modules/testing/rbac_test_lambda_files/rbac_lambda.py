import urllib3
import json
import os
import time
import sys

http = urllib3.PoolManager()

# Environment Variables
host = (os.environ["HOST_URL"] + ":8998") if "HOST_URL" in os.environ else "http://test_host.com:8998"
database_name = os.environ["DB_NAME"] if "DB_NAME" in os.environ else "test_database"
pii_table_name = os.environ["PII_TABLE"] if "PII_TABLE" in os.environ else "test_pii_table"
non_pii_table_name = os.environ["NON_PII_TABLE"] if "NON_PII_TABLE" in os.environ else "test_non_pii_table"
proxy_user = os.environ["PROXY_USER"] if "PROXY_USER" in os.environ else "test_user"

access_denied_message = "Service: Amazon S3; Status Code: 403; Error Code: AccessDenied"


def lambda_handler(context, event):
    # kill_all_sessions()
    session_url = start_session()
    use_database(session_url)
    check_for_access_denied(session_url)
    check_for_access_granted(session_url)
    kill_session(session_url)


def initial_request(url, code):
    print(code)
    r = http.request('POST',
                     url,
                     body=json.dumps(code),
                     headers={'Content-Type': 'application/json'})
    response = json.loads(r.data.decode('utf-8'))
    print(response)
    status_url = host + r.headers['location']
    return status_url


def poll_for_result(session_url, status_url):
    while True:
        print("Polling url: ", status_url)
        poll = http.request('GET', status_url)
        response = json.loads(poll.data.decode('utf-8'))
        state = response['state']
        print("Current state =", state)
        if state == "available" or state == "idle":
            return response
        else:
            time.sleep(5)


###################
# Helper Functions
###################

# Create a session and poll until the session is ready
def start_session():
    print("Attempting to start a session with Spark")
    code = {
        'kind': 'spark',
        'proxyUser': proxy_user
    }
    url = host + '/sessions'
    session_url = initial_request(url, code)
    poll_for_result(session_url, session_url)
    print("SESSION ESTABLISHED")
    return session_url


# When finished, kill the session
def kill_session(session_url):
    print("Killing session", session_url)
    http.request(
        'DELETE',
        session_url
    )

def kill_all_sessions():
    url = host + "/sessions/"
    for i in range(1, 50):
        http.request(
            'DELETE',
            url + str(i)
        )

def use_database(session_url):
    print("Selecting Database to use")
    statements_url = session_url + '/statements'
    code = {'code': f'spark.sql("USE {database_name}")'}
    status_url = initial_request(statements_url, code)
    response = poll_for_result(session_url, status_url)
    print(response)
    print("Using Database", database_name)

#############
# Test RBAC #
#############
# Attempt to access a table with the pii:true tag - should receive 403 error
def check_for_access_denied(session_url):
    print("Attempting to access PII data")
    statements_url = session_url + '/statements'
    code = {'code': f'spark.sql("select * from {pii_table_name}")'}
    status_url = initial_request(statements_url, code)
    response = poll_for_result(session_url, status_url)
    if access_denied_message in response['output']['evalue']:
        print("Expected 403 - Got 403")
        return "OK"
    else:
        kill_session(session_url)
        print(response['output']['evalue'])
        sys.exit('Excepted 403 - But did not receive access denied')


# Attempt to access a table with the pii:false tag - should be successful
def check_for_access_granted(session_url):
    print("Attempting to access Non PII data")
    statements_url = session_url + '/statements'
    code = {'code': f'spark.sql("select * from {non_pii_table_name}")'}
    status_url = initial_request(statements_url, code)
    response = poll_for_result(session_url, status_url)
    print(response)
    if response['output']['status'] != "error":
        print("Expected no error - No error found")
        return "OK"
    else:
        kill_session(session_url)
        print(response['output']['evalue'])
        sys.exit('Excepted data - Received an error')
