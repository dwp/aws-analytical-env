#!/usr/bin/env bash
# livy_client_conf.sh

set -e
set -u
set -x
set -o pipefail

(

    echo -n "Running as: "
    whoami

    cat >> /tmp/livy-client.conf <<EOF
    livy.client.http.connection.socket.timeout = ${livy_client_http_connection_socket_timeout}
    livy.client.http.connection.timeout        = ${livy_client_http_connection_timeout}
    livy.rsc.client.connect.timeout            = ${livy_rsc_client_connect_timeout}
    livy.rsc.client.shutdown-timeout           = ${livy_rsc_client_shutdown_timeout}
    livy.rsc.job-cancel.timeout                = ${livy_rsc_job_cancel_timeout}
    livy.rsc.job-cancel.trigger-interval       = ${livy_rsc_job_cancel_trigger_interval}
    livy.rsc.retained-statements               = ${livy_rsc_retained_statements}
    livy.rsc.server.connect.timeout            = ${livy_rsc_server_connect_timeout}
EOF

    sudo mv /tmp/livy-client.conf /etc/livy/conf/livy-client.conf
    sudo chown root:root /etc/livy/conf/livy-client.conf
    sudo chmod 644 /etc/livy/conf/livy-client.conf
    sudo ln -s /etc/livy/conf/livy-client.conf /etc/spark/conf/livy-client.conf

    sudo systemctl stop livy-server
    sleep 5
    sudo systemctl start livy-server

) >> /var/log/batch/livy_client_conf.log 2>&1
