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

echo "*****************************************"

PACKAGES_ARR=($${PACKAGES//;/ })
for i in "$${PACKAGES_ARR[@]}"
do
    :
    echo "  Installing $${i}"
    echo "*****************************************"
    sudo R -e "Sys.setenv(http_proxy = '${full_proxy}'); Sys.setenv(https_proxy = '${full_proxy}'); install.packages('$${i}', repos='https://cran.rstudio.com/')" 1>&2
done
