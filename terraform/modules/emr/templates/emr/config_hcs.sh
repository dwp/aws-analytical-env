#!/usr/bin/env bash

set +e

(
    # Import the logging functions
    source /opt/emr/logging.sh


    install_tenable="$9"
    install_trend="${10}"
    install_tanium="${11}"


    log_message "Populate tags required for HCS..."
    # Import tenable Linking Key
    source /etc/environment
    
    export TECHNICALSERVICE="DataWorks"
    export ENVIRONMENT="$1"
    echo "$TECHNICALSERVICE"
    echo "$ENVIRONMENT"


    if [ "$install_tenable" = true ]; then
        echo "Configuring tenable agent"
        sudo /opt/nessus_agent/sbin/nessuscli agent link --key="$TENABLE_LINKING_KEY" --cloud --groups="$TECHNICALSERVICE"_"$ENVIRONMENT",TVAT --proxy-host="$2" --proxy-port="$3"
    else
        echo "Flag set to skip Tenable installation"
    fi

    if [ "$install_trend" = true ]; then

        echo Installing and configuring Trend Micro Agent
        # PROXY_ADDR_PORT and PROXY_CREDENTIAL define proxy for software download and Agent activation
        PROXY_ADDR_PORT="$2:$3"
        # RELAY_PROXY_ADDR_PORT and RELAY_PROXY_CREDENTIAL define proxy for Agent and Relay communication
        RELAY_PROXY_ADDR_PORT="$2:$3"
        # HTTP_PROXY is exported for compatibility purpose, remove it if it is not needed in your environment 
        export HTTP_PROXY=http://$PROXY_ADDR_PORT/
        export HTTPS_PROXY=http://$PROXY_ADDR_PORT/

        ACTIVATIONURL='dsm://agents.deepsecurity.trendmicro.com:443/'
        MANAGERURL='https://app.deepsecurity.trendmicro.com:443'
        CURLOPTIONS='-s --tlsv1.2'
        linuxPlatform='';
        isRPM='';

        # if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        #     echo You are not running as the root user.  Please try again with root privileges.;
        #     exit 1;
        # fi;

        if ! type curl >/dev/null 2>&1; then
            echo "Please install CURL before running this script."
            exit 1
        fi

        _CURLOUT=$(eval curl "$CURLOPTIONS" --location "$MANAGERURL"/software/deploymentscript/platform/linuxdetectscriptv1/ -o /tmp/PlatformDetection -x "$PROXY_ADDR_PORT";)
        err=$?
        if [[ $err -eq 60 ]]; then
            echo "TLS certificate validation for the agent package download has failed. Please check that your Workload Security Manager TLS certificate is signed by a trusted root certificate authority. For more information, search for \"deployment scripts\" in the Deep Security Help Center."
            exit 1;
        fi

        if [ -s /tmp/PlatformDetection ]; then
            . /tmp/PlatformDetection
        else
            echo "Failed to download the agent installation support script."
            exit 1
        fi

        platform_detect
        if [[ -z "${linuxPlatform}" ]] || [[ -z "${isRPM}" ]]; then
            echo Unsupported platform is detected
            exit 1
        fi

        echo Downloading agent package...
        if [[ $isRPM == 1 ]]; then package='agent.rpm'
            else package='agent.deb'
        fi
        curl -H 'Agent-Version-Control: on' -L "$MANAGERURL"/software/agent/"${runningPlatform}""${majorVersion}"/"${archType}"/$package?tenantID="${15}" -o /tmp/$package -x "$PROXY_ADDR_PORT"
        sleep 5

        echo Installing agent package...
        rc=1
        if [[ $isRPM == 1 && -s /tmp/agent.rpm ]]; then
            sudo rpm -ihv /tmp/agent.rpm
            rc=$?
        elif [[ -s /tmp/agent.deb ]]; then
            sudo dpkg -i /tmp/agent.deb
            rc=$?
        else
            echo Failed to download the agent package. Please make sure the package is imported in the Workload Security Manager
            exit 1
        fi
        if [[ ${rc} != 0 ]]; then
            echo Failed to install the agent package
            exit 1
        fi

        echo Installed the agent package successfully

        sleep 15
        sudo /opt/ds_agent/dsa_control -r
        sudo /opt/ds_agent/dsa_control -x dsm_proxy://"$PROXY_ADDR_PORT"/
        sudo /opt/ds_agent/dsa_control -y relay_proxy://"$RELAY_PROXY_ADDR_PORT"/
        sudo /opt/ds_agent/dsa_control -a $ACTIVATIONURL "tenantID:${12}" "token:${13}" "policyid:${14}"
        # Checks for successful installation
        sudo /opt/ds_agent/dsa_query -c "GetComponentInfo" -r "au" "AM.mode"
    else
        echo "Flag set to skip Trend installation"
    fi

    if [ "$install_tanium" = true ]; then   
        log_message "Installing and configuring Tanium"
        sudo rpm -Uvh /opt/agents/tanium/TaniumClient-*
        echo "set ServerNameList $4,$5"
        sudo /opt/Tanium/TaniumClient/TaniumClient config set ServerNameList "$4,$5"
        echo "set LogVerbosityLevel $8"
        sudo /opt/Tanium/TaniumClient/TaniumClient config set LogVerbosityLevel "$8"
        echo "set ServerPort $7"
        sudo /opt/Tanium/TaniumClient/TaniumClient config set ServerPort "$7"
        echo "set environment tanium-init.dat.$6 "
        sudo cp "/opt/Tanium/TaniumClient/tanium-init.dat.$6" /opt/Tanium/TaniumClient/tanium-init.dat
        sudo mkdir /opt/Tanium/TaniumClient/Tools
        echo "Start Tanium Service"
        sudo systemctl enable --now taniumclient.service
        echo "Set Tanium specific tags"
        echo TechnicalService:"$TECHNICALSERVICE" >>/opt/Tanium/TaniumClient/Tools/CustomTags.txt
        echo "Check Tanium status"
        sudo systemctl status taniumclient
    else
        echo "Flag set to skip Tanium installation"
    fi


)   >> /var/log/hcs/config_hcs.log 2>&1

