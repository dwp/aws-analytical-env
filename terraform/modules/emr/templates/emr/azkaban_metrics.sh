#!/bin/bash

metrics::started() {
    local -r job=$${1:?Usage: $${FUNCNAME[0]} job step}
    local -r step=$${2:?Usage: $${FUNCNAME[0]} job step}
    metrics::push "$job" "$step" 1
}

metrics::succeeded() {
    local -r job=$${1:?Usage: $${FUNCNAME[0]} job step}
    local -r step=$${2:?Usage: $${FUNCNAME[0]} job step}
    metrics::push "$job" "$step" 2
}

metrics::failed() {
    local -r job=$${1:?Usage: $${FUNCNAME[0]} job step}
    local -r step=$${2:?Usage: $${FUNCNAME[0]} job step}
    metrics::push "$job" "$step" 3
}

metrics::push() {
    local -r job=$${1:?Usage: $${FUNCNAME[0]} job step value}
    local -r step=$${2:?Usage: $${FUNCNAME[0]} job step value}
    local -ir value=$${3:?Usage $${FUNCNAME[0]} job step value}
    echo $(date '+%Y-%m-%d %H:%M:%S') Pushing metrics, job: "$job", step: "$step", value: "$value".
    curl -sS --data-binary @- $(metrics::pushgateway_url $job $step) <<EOF
# TYPE azkaban_job_status gauge
# HELP azkaban_job_status 1 = job started, 2 = job succeeded, 3 = job failed.
azkaban_job_status{run_date="$(metrics::run_date)", cluster_id="$(metrics::cluster_id)", flow="$job/$${step%.*}"} $value
EOF
    local -r result=$?
    echo $(date '+%Y-%m-%d %H:%M:%S') Pushed metrics, job: "$job", step: "$step", value: "$value", result "$result".

}

metrics::delete() {
    local -r job=$${1:?Usage: $${FUNCNAME[0]} job step}
    local -r step=$${2:?Usage: $${FUNCNAME[0]} job step}

    echo $(date '+%Y-%m-%d %H:%M:%S') deleting metrics, job: "$job", step: "$step".

    curl -X DELETE $(metrics::pushgateway_url $job $step)
    local -r result=$?
    echo $(date '+%Y-%m-%d %H:%M:%S') deleted metrics, job: "$job", step: "$step", result "$result".
}

metrics::wipe() {
    echo $(date '+%Y-%m-%d %H:%M:%S') "Flushing Azkaban pushgateway".
    sleep 120
    curl -X PUT "http://${azkaban_pushgateway_hostname}:9091/api/v1/admin/wipe"
    echo $(date '+%Y-%m-%d %H:%M:%S') "Done flushing Azkaban pushgateway".
}

metrics::pushgateway_url() {
    local -r job=$${1:?Usage: $${FUNCNAME[0]} job step}
    local -r step=$${2:?Usage: $${FUNCNAME[0]} job step}
    # shellcheck disable=SC2154
    # shellcheck disable=SC2086
    # these are template file constructs not shell script constructs.
    echo http://${azkaban_pushgateway_hostname}:9091/metrics/job/$job/instance/$(metrics::instance_name)/step/$${step%.*}
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
    echo "$run_date"
}

export run_date=$(date +%F)
