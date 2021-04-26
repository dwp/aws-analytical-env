import os
from enum import Enum
from typing import Union


class ConfigKeys(Enum):
    database_cluster_arn = 'DATABASE_CLUSTER_ARN'
    database_name = 'DATABASE_NAME'
    database_secret_arn = 'SECRET_ARN'
    common_tags = 'COMMON_TAGS'
    assume_role_policy_json = 'ASSUME_ROLE_POLICY_JSON'
    s3fs_bucket_arn = 'S3FS_BUCKET_ARN'
    s3fs_kms_arn = 'S3FS_KMS_ARN'
    region = 'REGION'
    mgmt_account = 'MGMT_ACCOUNT_ROLE_ARN'
    user_pool_id = 'COGNITO_USERPOOL_ID'


Config = dict[ConfigKeys, Union[str, dict]]


# Gets env vars passed in from terraform as strings and builds the variables dict.
def get_config() -> Config:
    common_tags_string = os.getenv('COMMON_TAGS')
    tag_separator = ","
    key_val_separator = ":"
    config: Config = dict(map(lambda item: (item, os.getenv(item.value)), ConfigKeys.__members__.values()))
    config[ConfigKeys.common_tags] = dict()

    common_tags = common_tags_string.split(tag_separator)
    for tag in common_tags:
        key, value = tag.split(key_val_separator)
        config[ConfigKeys.common_tags][key] = value

    for k, v in config.items():
        if v is None or v == {}:
            raise NameError(f'Variable: {k.value} has not been provided.')
    return config
