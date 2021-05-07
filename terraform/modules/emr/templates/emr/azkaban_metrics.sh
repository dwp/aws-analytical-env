#!/bin/bash

metrics::started() {
    local -r job=${1:?Usage: ${FUNCNAME[0]} job}
    metrics::push "$job" 1
}

metrics::succeeded() {
    local -r job=${1:?Usage: ${FUNCNAME[0]} job}
    metrics::push "$job" 2
}

metrics::failed() {
    local -r job=${1:?Usage: ${FUNCNAME[0]} job}
    metrics::push "$job" 3
}

metrics::push() {
    local -r job=${1:?Usage ${FUNCNAME[0]} job value}
    local -ir value=${2:?Usage ${FUNCNAME[0]} job value}
    curl -sS -w %{http_code} --data-binary @- $(metrics::pushgateway_url $job) <<EOF
# TYPE azkaban_job_status gauge
# HELP azkaban_job_status 1 = job started, 2 = job succeeded, 3 = job failed.
azkaban_job_status{run_date="$(metrics::run_date)", cluster_id="$(metrics::cluster_id)"} $value
EOF
}

metrics::delete() {
    local -r job=${1:?Usage ${FUNCNAME[0]} job value}
    curl -X DELETE $(metrics::pushgateway_url $job)
}

metrics::pushgateway_url() {
    local -r job=${1:?Usage ${FUNCNAME[0]} job}
    echo http://pushgateway:9091/metrics/job/$job/instance/$(metrics::instance_name)
}

metrics::cluster_id() {
    local -r job_flow=/var/lib/info/job-flow.json
    if [[ -f $job_flow ]]; then
        jq -r .jobFlowId < $job_flow
    else
        echo unknown
    fi
}

metrics::instance_name() {
    hostname
}

metrics::run_date() {
    date +%F
}
