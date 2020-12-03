SOURCE_LOCATION=$1
DESTINATION_LOCATION=$2

BUCKET="${config_bucket}"

SOURCE_PATH=$BUCKET/$SOURCE_LOCATION

(
    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_message "$${1}" "get_scripts.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }
    echo "Start Downloading files from $SOURCE_LOCATION to $DESTINATION_LOCATION"
    log_wrapper_message "Start Downloading files from $SOURCE_LOCATION to $DESTINATION_LOCATION"

    aws s3 cp $SOURCE_PATH $DESTINATION_LOCATION --recursive
    
    echo "Finish downlaoding file from $SOURCE_LOCATION to $DESTINATION_LOCATION"
    log_wrapper_message "Finish downlaoding file from $SOURCE_LOCATION to $DESTINATION_LOCATION"

)  >> /var/log/get_scripts.log 2>&1







