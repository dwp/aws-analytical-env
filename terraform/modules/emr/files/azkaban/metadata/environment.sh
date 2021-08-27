#!/usr/bin/env bash

source "${AZKABAN_JOB_UTILITY_HOME:-/opt/emr/azkaban}/common/environment.sh"

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
metadata::metadata() {

    local -r input_directory=${1:?Usage: ${FUNCNAME[0]} input-directory}

    for input_file in "$input_directory"/*; do
        if metadata::is_tar_file "$input_file"; then
            metadata::tar_file_metadata "$input_file"
        elif metadata::is_zip_file "$input_file"; then
            metadata::zip_file_metadata "$input_file"
        fi
    done
}

metadata::tar_file_metadata() {
    local -r input_file=${1:?Usage: ${FUNCNAME[0]} input_file}

    local -r input_file_name=$(metadata::file_name "$input_file")
    local -r input_file_size=$(metadata::file_size "$input_file")

    tar tvf "$input_file" \
        | awk -v size="$input_file_size" \
              -v name="$input_file_name" \
              '{
                 OFS = "|";
                 n = split($6, xs, "/");
                 print name, size, xs[n], $3
               }'

}

metadata::zip_file_metadata() {
    local -r input_file=${1:?Usage: ${FUNCNAME[0]} input_file}

    local -r input_file_name=$(metadata::file_name "$input_file")
    local -r input_file_size=$(metadata::file_size "$input_file")

    unzip -l "$input_file" \
        | head -n -2 | tail -n +4 \
        | awk -v size="$input_file_size" \
              -v name="$input_file_name" \
              '{
                 OFS = "|";
                 print name, size, $4, $1
               }'
}

metadata::is_tar_file() {
    local filename=${1:?Usage: ${FUNCNAME[0]} filename}
    metadata::is_file_with_extension tar "$filename"
}

metadata::is_zip_file() {
    local filename=${1:?Usage: ${FUNCNAME[0]} filename}
    metadata::is_file_with_extension zip "$filename"
}

metadata::is_file_with_extension() {
    local extension=${1:?Usage: ${FUNCNAME[0]} extension filename}
    local filename=${2:?Usage: ${FUNCNAME[0]} extension filename}
    local -r re='\.'$extension'$'
    [[ $filename =~ $re ]]
}

metadata::file_name() {
    local -r input_file=${1:?Usage: ${FUNCNAME[0]} input_file}
    basename "$input_file"
}

metadata::file_size() {
    local -r input_file=${1:?Usage: ${FUNCNAME[0]} input_file}
    du -b "$input_file" | cut -f1
}
