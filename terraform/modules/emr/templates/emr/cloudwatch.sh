#!/bin/bash
set -Eeuo pipefail

cwa_metrics_collection_interval="$1"
cwa_log_group_name="$2"
aws_default_region="$3"
cwa_namespace="$4"

# Create config file required for CloudWatch Agent
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<CWAGENTCONFIG
{
  "agent": {
    "metrics_collection_interval": $${cwa_metrics_collection_interval},
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/batch/get_scripts.log",
            "log_group_name": "$${cwa_log_group_name}",
            "log_stream_name": "get_scripts.log",
            "timezone": "UTC"
          }
        ]
      }
    },
    "log_stream_name": "$${cwa_namespace}",
    "force_flush_interval": 15
  }
}
CWAGENTCONFIG

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo systemctl start amazon-cloudwatch-agent



