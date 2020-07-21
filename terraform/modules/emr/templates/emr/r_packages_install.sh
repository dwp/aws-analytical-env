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

# Install the R development tools
sudo yum install -y R-devel gcc gcc-c++ gcc-gfortran readline-devel cairo-devel libpng-devel libjpeg-devel libtiff-devel libcurl-devel curl-devel

## Update R
cd $HOME
sudo yum-config-manager --enable epel
sudo yum install pcre2-devel -y
mkdir R-latest
cd R-latest
wget http://cran.rstudio.com/src/base/R-latest.tar.gz
tar -xzf R-latest.tar.gz
cd R-4*
./configure --with-readline=yes --enable-R-profiling=no --enable-memory-profiling=no --enable-R-shlib --with-pic --prefix=/usr --without-x --with-libpng --with-jpeglib --with-cairo --enable-R-shlib --with-recommended-packages=yes
make -j 8
sudo make install

###############################
PACKAGES="${packages}"

while [[ $# > 1 ]]; do
    key="$1"

    case $key in
        # The packages to install separated by semicolon
        # Eg: --packages magrittr;dplyr
        --packages)
            PACKAGES="$2"
            shift
            ;;
        *)
            echo "Unknown option: $${key}"
            exit 1;
    esac
    shift
done

PACKAGES_ARR=($${PACKAGES//;/ })
PCK=""
for i in "$${PACKAGES_ARR[@]}"
do
    :
    PCK="$${PCK}'$${i}',"
done
PCK="$${PCK%?}" # Remove last comma
sudo R -e "options(Ncpus = parallel::detectCores()); Sys.setenv(http_proxy = '${full_proxy}'); Sys.setenv(https_proxy = '${full_proxy}'); install.packages(c($PCK), repos='https://cran.rstudio.com/')" 1>&2
