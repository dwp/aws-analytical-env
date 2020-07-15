#!/usr/bin/env bash

set -e
set -u
set -x
set -o pipefail

echo -n "Running as: "
whoami

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
