#!/usr/bin/env bash

set -e
set -u
set -x
set -o pipefail

(

    echo -n "Running as: "
    whoami

    export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)
    FULL_PROXY="${full_proxy}"
    FULL_NO_PROXY="${full_no_proxy}"
    export http_proxy="$FULL_PROXY"
    export HTTP_PROXY="$FULL_PROXY"
    export https_proxy="$FULL_PROXY"
    export HTTPS_PROXY="$FULL_PROXY"
    export no_proxy="$FULL_NO_PROXY"
    export NO_PROXY="$FULL_NO_PROXY"

    sudo -E wget https://github.com/sparklyr/sparklyr/blob/15cf7cbb32eb5247f47db5c4febe21b9bba43105/inst/java/sparklyr-3.0-2.12.jar?raw=true -O /usr/lib/spark/jars/sparklyr-3.0-2.12.jar

) >> /var/log/batch/sparkR_install.log 2>&1
