#!/usr/bin/env bash

source "${AZKABAN_JOB_UTILITY_HOME:-/opt/emr/azkaban}/chunk/environment.sh"

OPTIND=1

options=":p:s:"

while getopts "$options" opt; do
    case $opt in
        p)
            optional_prefix=$OPTARG
            ;;
        s)
            optional_chunk_size=$OPTARG
            ;;
        \?)
            console::stderr Usage: "${FUNCNAME[0]}" [ "$options" ] source-directory target-directory
            return 2
            ;;
    esac
done

shift $((OPTIND - 1))

source_directory=${1:?Usage: ${FUNCNAME[0]} $options source-directory target-directory}
target_directory=${2:?Usage: ${FUNCNAME[0]} $options source-directory target-directory}

chunk::chunk ${optional_prefix:+-p $optional_prefix} \
             ${optional_chunk_size:+-s $optional_chunk_size} \
             "$source_directory" "$target_directory"