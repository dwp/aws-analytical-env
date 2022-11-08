#!/usr/bin/env bash

set -e
set -u
set -x
set -o pipefail

echo -n "Running as: $USER"

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f4)
FULL_PROXY="${full_proxy}"
FULL_NO_PROXY="${full_no_proxy}"
export http_proxy="$FULL_PROXY"
export HTTP_PROXY="$FULL_PROXY"
export https_proxy="$FULL_PROXY"
export HTTPS_PROXY="$FULL_PROXY"
export no_proxy="$FULL_NO_PROXY"
export NO_PROXY="$FULL_NO_PROXY"

# building pandas from source requires installing a C compiler so just get a binary.
cat <<EOF > $HOME/py_requirements.txt
--only-binary=:pandas:
dfply==0.3.3
dplython==0.0.7
fuzzywuzzy==0.18.0
kaleido==0.2.1
keras==2.4.3
nltk==3.6.1
numpy==1.17.3
openpyxl==3.0.7
pandas==1.2.5
PyDriller==2.0
python-docx==0.8.11
python-Levenshtein==0.12.2
scikit-learn==0.24.1
scikit-spark==0.4.0
scipy==1.6.2
seaborn==0.11.1
spark-nlp==3.0.1
statsmodels==0.12.2
torch==1.8.1
yake==0.4.7
EOF

sudo -E pip3 install --upgrade pip setuptools
sudo yum install -y python3-devel
sudo -E pip3 install -r $HOME/py_requirements.txt
sudo yum remove -y python3-devel

rm -f $HOME/py_requirements.txt
