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
    proxy_user = context["proxy_user"]
    table = context["table"]
    access = context["user_access"]
    database_name = context["db_name"]

    session_url = start_session(proxy_user)
    use_database(session_url, database_name)
    check_access_is_correct(session_url, table, access)
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
def check_access_is_correct(session_url, table, access):
    statements_url = session_url + '/statements'
    code = {'code': f'spark.sql("select * from {table["name"]}")'}
    status_url = initial_request(statements_url, code)
    response = poll_for_result(session_url, status_url)
    print(response)

    # Should have full access to all data
    if access == "pii":
        # Error - exit and print error
        if response['output']['status'] == "error":
            kill_session(session_url)
            print(response['output']['evalue'])
            sys.exit('Expected data - Received error')
        # Received data as expected
        else:
            kill_session(session_url)
            print("Expected data - Received data")
            return "OK"

    # Should only have access to non-pii data
    if access == "non_pii":
        # Should receive 403 when trying to access pii data
        if table["type"] == "pii" and access_denied_message in response['output']['evalue']:
            kill_session(session_url)
            print("Expected 403 - received 403")
            return "OK"
        # Error - exit and print error
        elif response['output']['status'] == "error":
            kill_session(session_url)
            print(response['output']['evalue'])
            sys.exit('Expected data - Received error')
        # Finally, if no error, then non-pii data was returned as expected
        else:
            kill_session(session_url)
            print("Expected data - Received data")
            return "OK"
