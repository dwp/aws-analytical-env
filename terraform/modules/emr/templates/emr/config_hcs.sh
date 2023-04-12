#!/usr/bin/env bash

(
    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_batch_message "$${1}" "config_hcs.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    log_wrapper_message "Populate tags..."
    
    # Import tenable Linking Key
    source /etc/environment
    
    export TECHNICALSERVICE="DataWorks"
    export ENVIRONMENT="$1"

    echo "$TECHNICALSERVICE"
    echo "$ENVIRONMENT"

    log_wrapper_message "Configuring tenable agent"

    sudo /opt/nessus_agent/sbin/nessuscli agent link --key="$TENABLE_LINKING_KEY" --cloud --groups="$TECHNICALSERVICE"_"$ENVIRONMENT",TVAT --proxy-host="$2" --proxy-port="$3"



)   >> /var/log/batch/config_hcs.log 2>&1