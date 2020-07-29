#!/usr/bin/env bash

set -e
set -u
set -x
set -o pipefail

echo -n "Running as: "
whoami

#####################
# Setup Environment #
#####################
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

################
# Yum Packages #
################
sudo yum install -y gcc gcc-c++ gcc-gfortran readline-devel cairo-devel libpng-devel libjpeg-devel libtiff-devel libcurl-devel bzip2-devel unixODBC-devel
cd $HOME
sudo yum-config-manager --enable epel
sudo yum-config-manager --setopt=epel.baseurl='http://mirrors.coreix.net/fedora-epel/6/$basearch' --setopt=epel.proxy=$FULL_PROXY --save
sudo yum install pcre2-devel pcre-devel v8-devel -y
sudo yum-config-manager --disable epel
sudo mkdir /opt/R/R-${r_version} -p
sudo chmod 755 /opt/R/R-${r_version}

##############
#  Update R  #
##############
cd $HOME
mkdir R-update
cd R-update
wget http://cran.rstudio.com/src/base/R-3/R-${r_version}.tar.gz
tar -xzf R-${r_version}.tar.gz
cd R-${r_version}
./configure --with-readline=yes --enable-R-profiling=no --enable-memory-profiling=no --enable-R-shlib --with-pic --prefix=/opt/R/R-${r_version} --without-x --with-libpng --with-jpeglib --with-cairo --enable-R-shlib --with-recommended-packages=yes
make -j 8
sudo make install

#####################
#  Install StringI  #
#####################
# This is required as the StringI packages is usually installed from third party repos, that aren't in proxy list
wget https://github.com/gagolews/stringi/archive/master.zip -O stringi.zip
unzip stringi.zip
sed -i '/\/icu..\/data/d' stringi-master/.Rbuildignore
sudo /opt/R/R-${r_version}/bin/R CMD build stringi-master
sudo /opt/R/R-${r_version}/bin/R CMD INSTALL stringi-master

######################
# Install R Packages #
######################
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
sudo /opt/R/R-${r_version}/bin/R -e "options(Ncpus = parallel::detectCores()); Sys.setenv(http_proxy = '${full_proxy}'); Sys.setenv(https_proxy = '${full_proxy}'); install.packages(c($PCK), repos='https://cran.rstudio.com/')" 1>&2

# Install archived R packages
sudo /opt/R/R-${r_version}/bin/R -e "Sys.setenv(http_proxy = '${full_proxy}'); Sys.setenv(https_proxy = '${full_proxy}'); require(devtools); install_version('RODBC', '1.3.15', repos='https://cran.rstudio.com')"
sudo /opt/R/R-${r_version}/bin/R -e "Sys.setenv(http_proxy = '${full_proxy}'); Sys.setenv(https_proxy = '${full_proxy}'); require(devtools); install_version('rmongodb', '1.8.0', repos='https://cran.rstudio.com')"

####################
# Cleanup Packages #
####################
sudo /opt/R/R-${r_version}/bin/R -e "Sys.setenv(http_proxy = '$FULL_PROXY'); Sys.setenv(https_proxy = '$FULL_PROXY'); remove.packages('devtools')"
sudo yum remove -y gcc gcc-c++ gcc-gfortran readline-devel cairo-devel libpng-devel libjpeg-devel libtiff-devel libcurl-devel bzip2-devel pcre-devel pcre2-devel bzip2-devel v8-devel unixODBC-devel
