#!/bin/bash


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
sft::chunked() {

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
                sft::stderr Usage: "${FUNCNAME[0]}" [ "$options" ] source-directory target-directory
                return 2
                ;;
        esac
    done

    shift $((OPTIND - 1))

    local -r source_directory=${1:?Usage: ${FUNCNAME[0]} $options source-directory target-directory}
    local -r target_directory=${2:?Usage: ${FUNCNAME[0]} $options source-directory target-directory}

    local -r chunk_size=${optional_chunk_size:-2G}
    local -r prefix=${optional_prefix:-DWX_AWS_$(date +'%Y%m%d')_BATCH_}

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


##########################################################################
#
# Writes metadata for all eligible files in the client supplied input directory.
#
# Metadata is produced for all zip files and tar files found in the input
# directory
#
# Logic ported from dip/chs-sft-transfer/chs-sft-transfer.sh
#
# Mandatory arguments:
#   input-directory
#
# Optional arguments:
#   None.
#
# Outputs:
#   Writes metadata to stdout. Clients should redirect or pipe as appropriate.
#
#   Format is slightly different depending on the file type. For tar files
#   each line is of the format:
#
#   tar_file_name|tar_file_size|tar_file_entry_minus_path|tar_file_entry_size
#
#   .. while for zip files it is
#
#   zip_file_name|zip_file_size|zip_file_entry_including_path|zip_file_entry_size
#
#############################################################################
sft::metadata() {

    local -r input_directory=${1:?Usage: ${FUNCNAME[0]} input-directory}

    for input_file in "$input_directory"/*; do
        if sft::is_tar_file "$input_file"; then
            sft::tar_file_metadata "$input_file"
        elif sft::is_zip_file "$input_file"; then
            sft::zip_file_metadata "$input_file"
        fi
    done
}

sft::tar_file_metadata() {
    local -r input_file=${1:?Usage: ${FUNCNAME[0]} input_file}

    local -r input_file_name=$(sft::file_name "$input_file")
    local -r input_file_size=$(sft::file_size "$input_file")

    tar tvf "$input_file" \
        | awk -v size="$input_file_size" \
              -v name="$input_file_name" \
              '{
                 OFS = "|";
                 n = split($6, xs, "/");
                 print name, size, xs[n], $3
               }'

}

sft::zip_file_metadata() {
    local -r input_file=${1:?Usage: ${FUNCNAME[0]} input_file}

    local -r input_file_name=$(sft::file_name "$input_file")
    local -r input_file_size=$(sft::file_size "$input_file")

    unzip -l "$input_file" \
        | head -n -2 | tail -n +4 \
        | awk -v size="$input_file_size" \
              -v name="$input_file_name" \
              '{
                 OFS = "|";
                 print name, size, $4, $1
               }'
}

sft::is_tar_file() {
    local filename=${1:?Usage: ${FUNCNAME[0]} filename}
    sft::is_file_with_extension tar "$filename"
}

sft::is_zip_file() {
    local filename=${1:?Usage: ${FUNCNAME[0]} filename}
    sft::is_file_with_extension zip "$filename"
}

sft::is_file_with_extension() {
    local extension=${1:?Usage: ${FUNCNAME[0]} extension filename}
    local filename=${2:?Usage: ${FUNCNAME[0]} extension filename}
    local -r re='\.'$extension'$'
    [[ $filename =~ $re ]]
}

sft::file_name() {
    local -r input_file=${1:?Usage: ${FUNCNAME[0]} input_file}
    basename "$input_file"
}

sft::file_size() {
    local -r input_file=${1:?Usage: ${FUNCNAME[0]} input_file}
    du -b "$input_file" | cut -f1
}

sft::stderr() {
    echo "$@" >&2
}
