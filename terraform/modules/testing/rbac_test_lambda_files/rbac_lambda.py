import urllib3
import json
import os
import time
import sys

http = urllib3.PoolManager()

# Environment Variables
host = (os.environ["HOST_URL"] + ":8998") if "HOST_URL" in os.environ else "http://test_host.com:8998"

access_denied_message = "Service: Amazon S3; Status Code: 403; Error Code: AccessDenied"


def lambda_handler(context, event):
    # kill_all_sessions()

    print("CONTEXT: ", context)
    proxy_user = context["proxy_user"] if "proxy_user" in context else "test_user"
    non_pii_table_name = context["non_pii_table"] if "non_pii_table" in context else "test_non_pii_table"
    pii_table_name = context["pii_table"] if "pii_table" in context else "test_pii_table"
    database_name = context["db_name"] if "db_name" in context else "test_database"

    session_url = start_session(proxy_user)
    use_database(session_url, database_name)
    check_for_access_denied(session_url, pii_table_name)
    check_for_access_granted(session_url, non_pii_table_name)
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
def start_session(proxy_user):
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


def use_database(session_url, database_name):
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
def check_for_access_denied(session_url, pii_table_name):
    print("Attempting to access PII data")
    statements_url = session_url + '/statements'
    code = {'code': f'spark.sql("select * from {pii_table_name}")'}
    status_url = initial_request(statements_url, code)
    response = poll_for_result(session_url, status_url)
    if access_denied_message in response['output']['evalue']:
        print("Expected 403 - Got 403")
        return "OK"
    elif response['output']['status'] == "error":
        kill_session(session_url)
        print(response['output']['evalue'])
        sys.exit('Excepted 403 - But received a different error')
    else:
        kill_session(session_url)
        print(response['output']['evalue'])
        sys.exit('Excepted 403 - But did not receive access denied')


# Attempt to access a table with the pii:false tag - should be successful
def check_for_access_granted(session_url, non_pii_table_name):
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
