import os
from enum import Enum
from typing import Union, Dict


class ConfigKeys(Enum):
    database_cluster_arn = 'DATABASE_CLUSTER_ARN'
    database_name = 'DATABASE_NAME'
    database_secret_arn = 'DATABASE_SECRET_ARN'
    common_tags = 'COMMON_TAGS'
    assume_role_policy_json = 'ASSUME_ROLE_POLICY_JSON'
    s3fs_bucket_arn = 'S3FS_BUCKET_ARN'
    s3fs_kms_arn = 'S3FS_KMS_ARN'
    region = 'REGION'
    mgmt_account = 'MGMT_ACCOUNT_ROLE_ARN'
    user_pool_id = 'COGNITO_USERPOOL_ID'


ConfigValue = Union[str, dict]
Config = Dict[ConfigKeys, ConfigValue]

_cfg: Union[Config, None] = None

def _init_config():
    global _cfg
    if _cfg is None:
        common_tags_string = os.environ['COMMON_TAGS']
        tag_separator = ","
        key_val_separator = ":"
        _cfg = dict(map(lambda item: (item, os.environ[item.value]), ConfigKeys.__members__.values()))

        _cfg[ConfigKeys.common_tags] = dict()
        common_tags = common_tags_string.split(tag_separator)
        for tag in common_tags:
            key, value = tag.split(key_val_separator)
            _cfg[ConfigKeys.common_tags][key] = value

        for k, v in _cfg.items():
            if v is None or v == {}:
                raise NameError(f'Variable: {k.value} has not been provided.')


def get_config(key: ConfigKeys = None) -> Union[Config, ConfigValue]:
    """
    Gets env vars and builds the variables dict.
    :return: config dict if key not specified, config value if key
    specified
    """
    global _cfg
    _init_config()
    return _cfg if key is None else _cfg[key]
