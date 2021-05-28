import urllib3
import json
import os
import time

http = urllib3.PoolManager()

# Environment Variables
host = (os.environ["HOST_URL"] + ":8998") if "HOST_URL" in os.environ else "http://test_host.com:8998"

access_denied_message = "Input path does not exist"


def lambda_handler(event, context):

    print("EVENT: ", event)

    is_simple_test = not all([var in event for var in ("proxy_user", "table", "db_name")])

    if is_simple_test:
        session_url = start_session(context)
        try:
            response = make_api_call(session_url, context)
            return response
        finally:
            kill_session(session_url)
    else:
        proxy_user = event["proxy_user"]
        table = event["table"]
        database_name = event["db_name"]

        session_url = start_session(context, proxy_user)
        try:
            use_database(session_url, database_name, context)
            response = make_api_call(session_url, context, table)
            return response
        finally:
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


def poll_for_result(session_url, status_url, context):
    while True:
        print("Polling url: ", status_url)
        poll = http.request('GET', status_url)
        response = json.loads(poll.data.decode('utf-8'))
        state = response['state']
        print("Current state =", state)
        if state == "available" or state == "idle":
            return response
        else:
            remaining_time = context.get_remaining_time_in_millis()
            if remaining_time < 10 * 1000:
                raise TimeoutError("Result not received within allocated lambda execution time")
            else:
                time.sleep(5)


###################
# Helper Functions
###################

# Create a session and poll until the session is ready
def start_session(context, proxy_user=None):
    print("Attempting to start a session with Spark")
    code = {
        'kind': 'pyspark',
    }
    if proxy_user is not None:
        code['proxyUser'] = proxy_user

    url = host + '/sessions'
    session_url = initial_request(url, code)
    poll_for_result(session_url, session_url, context)
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


def use_database(session_url, context, database_name):
    print("Selecting Database to use")
    statements_url = session_url + '/statements'
    code = {'code': f'spark.sql("USE {database_name}")'}
    status_url = initial_request(statements_url, code)
    response = poll_for_result(session_url, status_url, context)
    print(response)
    print("Using Database", database_name)


def make_api_call(session_url, context, table=None):
    statements_url = session_url + '/statements'
    stmt = "SELECT current_date()" if table is None else f"select * from {table}"
    code = {'code': f'spark.sql("{stmt}").collect()'}
    status_url = initial_request(statements_url, code)
    response = poll_for_result(session_url, status_url, context)
    print(response)
    return response
