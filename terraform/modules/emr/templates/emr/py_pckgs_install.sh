#!/usr/bin/env bash

set -e
set -u
set -x
set -o pipefail

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

cat <<EOF > /tmp/py_requirements.txt
--only-binary=:pandas:
nltk==3.6.1
yake==0.4.7
spark-nlp==3.0.1
scikit-learn==0.24.1
scikit-spark==0.4.0
torch==1.8.1
keras==2.4.3
scipy==1.6.2
pandas==1.3.0
numpy==1.17.3
seaborn==0.11.1
EOF

sudo -E pip3 install -r /tmp/py_requirements.txt || true
