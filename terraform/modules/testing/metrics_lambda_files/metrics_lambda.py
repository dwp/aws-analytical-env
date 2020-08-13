import datetime
import json
import os
import time
from urllib import parse

import boto3
import urllib3

cloudwatch = boto3.client("cloudwatch", region_name="eu-west-2")
http = urllib3.PoolManager()
# Environment Variables
host_url = os.environ["HOST_URL"]
host = host_url + ":8998" if "HOST_URL" in os.environ else "http://test_host.com:8998"
DOMAIN_WHITELIST = [parse.urlparse(host_url).hostname]


def lambda_handler(context, event):
    print("CONTEXT: ", context)
    proxy_user = context["proxy_user"]
    database_name = context["db_name"]
    table_names = context["table_names"]

    session_code = {'kind': 'sparkr', 'proxyUser': proxy_user}
    database_code = {'code': f'sql("USE {database_name}")'}

    # Initiate Session
    start_session_response = measure_response_time((host + '/sessions'), session_code)
    session_url = start_session_response[0]
    session_state_time_taken = start_session_response[1]
    publish_metrics("start_session", session_state_time_taken)

    # Connect to database and run queries against tables
    try:
        statements_url = session_url + '/statements'
        database_time_taken = measure_response_time(statements_url, database_code)[1]
        publish_metrics(f"use_database_{database_name}", database_time_taken)
        for table in table_names:
            table_code = {'code': f'sql("select * from {table}")'}
            time_taken = measure_response_time(statements_url, table_code)[1]
            print(f"query to {table} took {time_taken}")
            publish_metrics("select_all_from_" + table, time_taken)
        kill_session(session_url)
    except Exception as e:
        print(e)
        kill_session(session_url)


###################
# Helper Functions
###################
# When finished, kill the session
def kill_session(session_url):
    print("Killing session", session_url)
    http.request(
        'DELETE',
        session_url
    )


###################
# Capture Metrics
###################
def measure_response_time(url, code):
    started = datetime.datetime.now()
    print(f"Measure response time for code: {code}")
    # Send code to SparkR
    r = http.request('POST',
                     url,
                     body=json.dumps(code),
                     headers={'Content-Type': 'application/json'})
    response = json.loads(r.data.decode('utf-8'))
    print(response)
    status_url = host + r.headers['location']
    # Continuously check status until Available or Idle
    while True:
        print("Polling url: ", status_url)
        # Address Sonar Issues by checking url is in trusted domain
        if parse.urlparse(status_url).hostname in DOMAIN_WHITELIST:
            poll = http.request('GET', status_url)
            response = json.loads(poll.data.decode('utf-8'))
            state = response['state']
            print("Current state =", state)
            if state == "available" or state == "idle":
                print(response)
                break
            else:
                time.sleep(1)
    completed = datetime.datetime.now()
    if 'output' in response and response['output']['status'] == "error":
        elapsed_seconds = 0
    else:
        elapsed_seconds = (completed - started).total_seconds()
    return status_url, elapsed_seconds


###################
# Publish Metrics
###################
def publish_metrics(metric_name, metric_value):
    print(f"Publishing metric for {metric_name}")
    response = cloudwatch.put_metric_data(
        MetricData=[
            {
                'MetricName': metric_name,
                'Value': metric_value,
                'Unit': 'Seconds'
            },
        ],
        Namespace='/Analytical-Env/EMR_Response_Time',

    )
    print("CW Response", response)
