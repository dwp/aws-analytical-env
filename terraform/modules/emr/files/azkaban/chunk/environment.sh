#!/usr/bin/env bash

source "${AZKABAN_JOB_UTILITY_HOME:-/opt/emr/azkaban}/common/environment.sh"

##########################################################################
#
# Chunks the contents of a directory into equal sized parts which can later be
# concatenated and untar-ed to recreate the original directory contents. The
# contents a tar-ed and then the tar split.
#
# Logic ported from dip/chs-sft-transfer/chs-sft-transfer.sh
#
# Mandatory arguments:
#   input-directory: the source files location
#   output-directory: where the chunks will be written
#
# Optional arguments:
#   -s <size>: the size of the chunks. The default is 2Gb. The value should be
#              any value that is accepted by the split '--bytes|-b' option,
#              e.g. '2K', '1G' etc.
#
#   -p <prefix>: the chunk filename prefix, the default is
#               'DWX_AWS_$(date +'%Y%m%d')_BATCH_'
#
# Outputs:
#   The tar file split into chunks in the supplied output directory numbered
#   sequentially so that the tar can be recreated thus:
#   cat output_directory/*.tar.part > reconstituted.tar
#
#############################################################################
chunk::chunk() {

    OPTIND=1

    local -r options=":p:s:"

    while getopts "$options" opt; do
        case $opt in
            p)
                local -r optional_prefix=$OPTARG
                ;;
            s)
                local -r optional_chunk_size=$OPTARG
                ;;
            \?)
                console::stderr Usage: "${FUNCNAME[0]}" [ "$options" ] source-directory target-directory
                return 2
                ;;
        esac
    done

    shift $((OPTIND - 1))

    local -r source_directory=${1:?Usage: ${FUNCNAME[0]} $options source-directory target-directory}
    local -r target_directory=${2:?Usage: ${FUNCNAME[0]} $options source-directory target-directory}

    local -r chunk_size=${optional_chunk_size:-1G}
    local -r prefix=${optional_prefix:-AWS_UCFS_SAS_$(date +'%Y%m%d_%H%M%S')}

    fs::clear_directory "$target_directory"


    if tar -C "$source_directory" -cvf - . \
            | split --suffix-length 10 \
                    --bytes "${chunk_size}" \
                    --numeric-suffixes=1 \
                    - "${target_directory%/}/$prefix"; then

        local -r count=$(find "$target_directory" -maxdepth 1 -name "$prefix"'*' | wc -l)

        #Add default padding of 3
        if ((${#count} <= 3));
        then
            padding=3
        else
            padding=${#count}
        fi
        
        #Padding count with leading zeros
        printf -v padded_count "%0${padding}d" "$count"

        for file in "${target_directory%/}/${prefix}"*; do
            #get the file numeric suffix
            suffix=${file: -${padding}}
            #remove the numeric suffix from filename
            filename_nosuffix=${file::-10}
            mv "$file" "${filename_nosuffix}.tar.${suffix}-${padded_count}"
        done
    fi
}
