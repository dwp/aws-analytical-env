import datetime
import json
import os
import time
from urllib import parse

import boto3
import urllib3
import ssl

cloudwatch = boto3.client("cloudwatch", region_name="eu-west-2")

# Disable SSL Cert verification as there is a self-signed cert in our chain
http = urllib3.PoolManager(cert_reqs=ssl.CERT_NONE)
urllib3.disable_warnings()

# Environment Variables
host_url = os.environ["HOST_URL"]
host = host_url + ":8998" if "HOST_URL" in os.environ else "http://test_host.com:8998"
push_port = os.environ["PUSH_PORT"] if "PUSH_PORT" in os.environ else "9091"
push_host = os.environ["PUSH_HOST"]

DOMAIN_WHITELIST = [parse.urlparse(host_url).hostname]


def lambda_handler(context, event):
    print("CONTEXT: ", context)
    proxy_user = context["proxy_user"]
    database_name = context["db_name"]
    small_dataset = context["small_dataset"]
    large_dataset = context["large_dataset"]

    session_code = {'kind': 'sparkr', 'proxyUser': proxy_user}

    tests_code_snippets = [
        [f"use_database_{database_name}",
         {'code': f'sql("USE {database_name}")'}],
        [f"select_all_rows_from_{small_dataset}_limit_1",
         {'code': f'sql("SELECT * FROM {small_dataset} LIMIT 1")'}],
        [f"select_row_count_from_{small_dataset}",
         {'code': f'sql("SELECT COUNT(*) FROM {small_dataset}")'}],
        ["left_join_on_small_dataset",
         {'code': f'sql("SELECT COUNT(*) FROM {small_dataset} AS a LEFT JOIN {small_dataset} as b ON a.val = b.val")'}],
        ["left_join_on_large_dataset",
         {'code': f'sql("SELECT COUNT(*) FROM {large_dataset} AS a LEFT JOIN {large_dataset} as b ON a.val = b.val")'}],
        ["distinct_count_on_large_dataset", {'code': f'sql("SELECT COUNT(DISTINCT val) FROM {large_dataset}")'}],
    ]

    # Initiate Session
    start_session_response = measure_response_time((host + '/sessions'), session_code)
    session_url = start_session_response[0]
    session_state_time_taken = start_session_response[1]
    publish_metrics_to_cw("start_session", session_state_time_taken)
    push_metrics_to_pushgateway("start_session", session_state_time_taken)

    # Connect to database and run queries against tables
    try:
        statements_url = session_url + '/statements'
        for test, code in tests_code_snippets:
            time_taken = measure_response_time(statements_url, code)[1]
            print(f"{code} took {time_taken}")
            publish_metrics_to_cw(test, time_taken)
            push_metrics_to_pushgateway(test, time_taken)
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
def publish_metrics_to_cw(metric_name, metric_value):
    print(f"Publishing metric for {metric_name} to CW")
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


def push_metrics_to_pushgateway(name, value):
    print(f"Pushing metric {name} to Prometheus push gateway")
    pushgateway_url = f"https://{push_host}:{push_port}/metrics/job/analytical-env-emr-metrics/instance/{name}"
    response = http.request(
        "POST",
        pushgateway_url,
        body=f"{name} {value}",
    )
    print("Push_response", response.status_code)
