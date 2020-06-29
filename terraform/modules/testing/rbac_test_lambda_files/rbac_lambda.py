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
    database_name = context["db_name"]

    session_url = start_session(proxy_user)
    use_database(session_url, database_name)
    response = make_api_call(session_url, table)
    kill_session(session_url)
    return response


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


def make_api_call(session_url, table):
    statements_url = session_url + '/statements'
    code = {'code': f'spark.sql("select * from {table}")'}
    status_url = initial_request(statements_url, code)
    response = poll_for_result(session_url, status_url)
    print(response)
    return response
