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

export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8

# Install SparkR from source
sudo /opt/R/R-${r_version}/bin/R -e "Sys.setenv(http_proxy = '${full_proxy}'); Sys.setenv(https_proxy = '${full_proxy}'); install.packages('devtools', repos='https://cran.rstudio.com/')"
sudo /opt/R/R-${r_version}/bin/R -e "Sys.setenv(http_proxy = '${full_proxy}'); Sys.setenv(https_proxy = '${full_proxy}'); devtools::install_github('apache/spark@v2.4.4', subdir='R/pkg')"

cd /tmp/
wget https://github.com/apache/spark/archive/v2.4.4.zip
unzip v2.4.4.zip
cd spark-2.4.4
sudo cp -r R /usr/lib/spark/
cd bin
sudo cp sparkR /usr/lib/spark/bin/

cd /usr/lib/spark/R/
sudo sh install-dev.sh

### Cleanup R DevTools
sudo R -e "Sys.setenv(http_proxy = '$FULL_PROXY'); Sys.setenv(https_proxy = '$FULL_PROXY'); remove.packages('devtools')" || true

sudo sh -c "echo -e \\nexport SPARKR_DRIVER_R=/opt/R/R-${r_version}/bin/R >> /etc/spark/conf.dist/spark-env.sh"

sudo cp /opt/R/R-3.6.3/lib64/R/library/sparklyr/java/sparklyr-2.4-2.11.jar /usr/lib/spark/jars
