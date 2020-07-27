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

# Install the R development tools
sudo yum install -y gcc gcc-c++ gcc-gfortran readline-devel cairo-devel libpng-devel libjpeg-devel libtiff-devel libcurl-devel

# Use EPEL and install PCRE
cd $HOME
sudo yum-config-manager --enable epel
sudo yum-config-manager --setopt=epel.baseurl='http://mirrors.coreix.net/fedora-epel/6/$basearch' --setopt=epel.proxy=$FULL_PROXY --save
sudo yum install pcre2-devel pcre-devel -y
sudo yum-config-manager --disable epel

####################
# Install Packages #
####################
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

# Cleanup Yum Packages
sudo yum remove -y gcc gcc-c++ gcc-gfortran readline-devel cairo-devel libpng-devel libjpeg-devel libtiff-devel libcurl-devel bzip2-devel pcre-devel pcre2-devel
