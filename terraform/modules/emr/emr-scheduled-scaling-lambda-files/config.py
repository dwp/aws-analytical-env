import os
from enum import Enum
from typing import Union, Dict


class ConfigKeys(Enum):
    cluster_id = 'CLUSTER_ID'
    core_instance_group_id = 'INSTANCE_GROUP_ID'
    region = 'REGION'
    account = 'ACCOUNT'
    up_autoscaling_policy = 'UP_AUTOSCALING_POLICY'
    down_autoscaling_policy = 'DOWN_AUTOSCALING_POLICY'
    scale_up_rule_arn = 'SCALE_UP_RULE_ARN'
    scale_down_rule_arn = 'SCALE_DOWN_RULE_ARN'
    common_tags = 'COMMON_TAGS'


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

        _cfg[ConfigKeys['common_tags']] = dict()
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
