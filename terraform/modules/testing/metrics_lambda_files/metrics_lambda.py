import datetime
import json
import os
import time
import urllib3
import boto3

cloudwatch = boto3.client("cloudwatch", region_name="eu-west-2")

http = urllib3.PoolManager()

# Environment Variables
host = (os.environ["HOST_URL"] + ":8998") if "HOST_URL" in os.environ else "http://test_host.com:8998"


def lambda_handler(context, event):
    print("CONTEXT: ", context)
    proxy_user = context["proxy_user"]
    database_name = context["db_name"]
    table_names = context["table_names"]

    session_url = start_session(proxy_user)
    try:
        use_database(session_url, database_name)

        for table in table_names:
            time_taken = measure_response_time(session_url, table)
            print(f"query to ${table} took ${time_taken}")
            publish_metrics(table, time_taken)
    except Exception as e:
        print(e)
        kill_session(session_url)


###################
# Helper Functions
###################
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
            time.sleep(1)


# Create a session and poll until the session is ready
def start_session(proxy_user):
    print("Attempting to start a session with Spark")
    code = {
        'kind': 'sparkr',
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


def use_database(session_url, database_name):
    print("Selecting Database to use")
    statements_url = session_url + '/statements'
    code = {'code': f'sql("USE {database_name}")'}
    status_url = initial_request(statements_url, code)
    response = poll_for_result(session_url, status_url)
    print(response)
    print("Using Database", database_name)


def measure_response_time(session_url, table):
    code = {'code': f'head(sql("select * from {table}"))'}
    statements_url = session_url + '/statements'
    status_url = initial_request(statements_url, code)
    started = datetime.datetime.now()
    poll_for_result(session_url, status_url)
    completed = datetime.datetime.now()
    elapsed_seconds = completed - started
    kill_session(session_url)
    return elapsed_seconds.total_seconds()


def publish_metrics(table, seconds):
    print(f"Publishing metric for ${table}")
    response = cloudwatch.put_metric_data(
        MetricData=[
            {
                'MetricName': 'return_all_rows',
                'Dimensions': [
                    {
                        'Name': 'table',
                        'Value': table
                    }
                ],
                'Value': seconds
            },
        ],
        Namespace='/Analytical-Env/EMR_Response_Time',
    )
    print("CW Response", response)
