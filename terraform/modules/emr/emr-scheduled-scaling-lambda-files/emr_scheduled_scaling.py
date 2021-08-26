import logging
import boto3
from botocore.config import Config
from config import get_config, ConfigKeys

logger = logging.getLogger()
logger.level = logging.INFO

boto_config = Config(
    retries={
        'max_attempts': 5,
        'mode': 'standard'
    }
)

emr_client = boto3.client('emr', config=boto_config)

def lambda_handler(event, context):
    config = get_config()
    logging.info(f"event resource is: {event.get('resources')[0]}")
    if event.get('resources')[0] == config[ConfigKeys.scale_up_rule_arn]:
        logging.info(f"setting policy to scale up")
        policy = config[ConfigKeys.up_autoscaling_policy]
    elif event.get('resources')[0] == config[ConfigKeys.scale_down_rule_arn]:
        logging.info(f"setting policy to scale down")
        policy = config[ConfigKeys.down_autoscaling_policy]
    response = put_autoscaling_policy(policy)


def put_autoscaling_policy(policy):
    logger.info('updating EMR autoscaling policy')
    response = emr_client.put_auto_scaling_policy(
        ClusterId=get_config(ConfigKeys.cluster_id),
        InstanceGroupId=get_config(ConfigKeys.core_instance_group_id),
        AutoScalingPolicy=eval(policy)
    )
    return response