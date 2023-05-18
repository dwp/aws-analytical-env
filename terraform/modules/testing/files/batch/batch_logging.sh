#!/bin/bash

log_message() {
    message="${1}"
    log_level="${2}"
    app_version="${3}"
    process_id="${4}"
    application="${5}"
    component="${6}"
    environment="${7}"

    hostname="$HOSTNAME"
    timestamp=$(date +%FT%T.%3N)
    if [[ $timestamp == *".3N"* ]]; then
        timestamp=$(date +%FT%T)
    fi

    json_log="{\"timestamp\": \"$timestamp\", \"log_level\": \"$log_level\", \"message\": \"$message\"}"

    json=$(echo "$json_log" | jq  -c .)

    for var in "${@:8}"
    do
        set -f; IFS=','
        set -- "$var"
        read -r key value <<< "$var"
        set +f; unset IFS
        json=$(echo "$json" | jq -c --arg key_name "$key" --arg key_value "$value" '. + {($key_name): $key_value}')
    done

    json=$(echo "$json" | jq -c --arg key_name "process_id" --arg key_value "$process_id" '. + {($key_name): $key_value}')
    json=$(echo "$json" | jq -c --arg key_name "hostname" --arg key_value "$hostname" '. + {($key_name): $key_value}')
    json=$(echo "$json" | jq -c --arg key_name "environment" --arg key_value "$environment" '. + {($key_name): $key_value}')
    json=$(echo "$json" | jq -c --arg key_name "application" --arg key_value "$application" '. + {($key_name): $key_value}')
    json=$(echo "$json" | jq -c --arg key_name "app_version" --arg key_value "$app_version" '. + {($key_name): $key_value}')
    json=$(echo "$json" | jq -c --arg key_name "component" --arg key_value "$component" '. + {($key_name): $key_value}')

    echo "$json"
}

