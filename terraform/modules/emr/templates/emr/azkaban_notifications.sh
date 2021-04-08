#!/usr/bin/bash

# The following problems are because this is a template file and not the finished product.
# shellcheck disable=SC2125
# shellcheck disable=SC1083

notifications::notify_started() {
    local -r job=$${1:?Usage: $${FUNCNAME[0]} job step}
    local -r step=$${2:?Usage: $${FUNCNAME[0]} job step}
    notifications::send_message "$(notifications::starting_payload "$job" "$step")"
}

notifications::notify_completed() {
    local -ir exit_code=$${1:?Usage: $${FUNCNAME[0]} exit-code job step}
    local -r job=$${2:?Usage: $${FUNCNAME[0]} exit-code job step}
    local -r step=$${3:?Usage: $${FUNCNAME[0]} exit-code job step}

    if [[ "$exit_code" -eq 0 ]]; then
        notifications::notify_success "$job" "$step"
    else
        notifications::notify_failure "$job" "$step"
    fi
}

notifications::notify_success() {
    local -r job=$${1:?Usage: $${FUNCNAME[0]} job step}
    local -r step=$${2:?Usage: $${FUNCNAME[0]} job step}
    notifications::send_message "$(notifications::success_payload "$job" "$step")"
}

notifications::notify_failure() {
    local -r job=$${1:?Usage: $${FUNCNAME[0]} job step}
    local -r step=$${2:?Usage: $${FUNCNAME[0]} job step}
    notifications::send_message "$(notifications::failure_payload "$job" "$step")"
}

notifications::send_message() {
    local -r payload=$${1:?Usage: $${FUNCNAME[0]} payload}

    # shellcheck disable=SC2154
    aws sns publish \
        --topic-arn "${monitoring_topic_arn}" \
        --message "$payload"
}

notifications::starting_payload() {
    local -r job=$${1:?Usage: $${FUNCNAME[0]} step}
    local -r step=$${2:?Usage: $${FUNCNAME[0]} step}
    notifications::payload Medium Information "$job" "$step" "Azkaban step started."
}

notifications::success_payload() {
    local -r job=$${1:?Usage: $${FUNCNAME[0]} step}
    local -r step=$${2:?Usage: $${FUNCNAME[0]} step}
    notifications::payload Medium Information "$job" "$step" "Azkaban step succeeded."
}

notifications::failure_payload() {
    local -r job=$${1:?Usage: $${FUNCNAME[0]} step}
    local -r step=$${2:?Usage: $${FUNCNAME[0]} step}
    notifications::payload High Error "$job" "$step" "Azkaban step failed."
}

notifications::payload() {
    local -r severity=$${1:?Usage: $${FUNCNAME[0]} $(payload_required_arguments)}
    local -r notification_type=$${2:?Usage: $${FUNCNAME[0]} $(payload_required_arguments)}
    local -r job=$${3:?Usage: $${FUNCNAME[0]} $(payload_required_arguments)}
    local -r step=$${4:?Usage: $${FUNCNAME[0]} $(payload_required_arguments)}
    local -r title=$${5:?Usage: $${FUNCNAME[0]} $(payload_required_arguments)}

    cat <<EOF | jq .
{
    "severity": "$severity",
    "notification_type": "$notification_type",
    "slack_username": "AWS Azkaban Job Notification",
    "title_text": "$title",
    "custom_elements": [
        { "key": "Job", "value": "$job"},
        { "key": "Step", "value": "$step"}
    ]
}
EOF
}

notifications::payload_required_arguments() {
    echo severity notification_type job step title
}
