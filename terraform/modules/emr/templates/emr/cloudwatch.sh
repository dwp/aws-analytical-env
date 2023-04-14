#!/bin/bash
set -Eeuo pipefail

cwa_metrics_collection_interval="$1"
cwa_log_group_name="$2"
aws_default_region="$3"
cwa_namespace="$4"
cwa_si_namespace="$5"
cwa_si_log_group_name="$6"

# Create config file required for CloudWatch Agent
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<CWAGENTCONFIG
{
  "agent": {
    "metrics_collection_interval": ${cwa_metrics_collection_interval},
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/batch/get_scripts.log",
            "log_group_name": "${cwa_log_group_name}",  
            "log_stream_name": "{instance_id}_get_scripts.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hcs/config_hcs.log",
            "log_group_name": "${cwa_log_group_name}",  
            "log_stream_name": "{instance_id}_config_hcs.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/batch/create_dbs.log",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}_create_dbs.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/batch/hive_auth_conf.log",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}_hive_auth_conf.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/batch/hdfs_setup.log",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}_hdfs_setup.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/batch/sparkR_install.log",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}_sparkR_install.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/batch/livy_client_conf.log",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}_livy_client_conf.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hive/hive-server2.log",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}_hive_server2.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hive/hive-server2.out",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}_hive_server2.out",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hive/user/hadoop/hive.log",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}_hive_hadoop_user.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hive/user/hive/hive.log",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}_hive_hive_user.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hive/user/root/hive.log",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}_hive_root_user.log",
            "timezone": "UTC"
          }
        ] 
      }
    },
    "log_stream_name": "${cwa_namespace}",
    "force_flush_interval": 15
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/si/strategic_ingest.out",
            "log_group_name": "${cwa_si_log_group_name}",
            "log_stream_name": "{instance_id}_strategic_ingest.out", 
            "timezone": "UTC"
          }
        ] 
      }
    },
    "log_stream_name": "${cwa_si_namespace}",
    "force_flush_interval": 15
  }
}
CWAGENTCONFIG

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo systemctl start amazon-cloudwatch-agent

