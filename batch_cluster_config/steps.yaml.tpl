---
BootstrapActions:
- Name: "run-log4j-patch"
  ScriptBootstrapAction:
    Path: "s3://${config_bucket}/scripts/emr/patch-log4j-emr-6.3.1-v2.sh"
- Name: "get-dks-cert"
  ScriptBootstrapAction:
    Path: "s3://${config_bucket}/scripts/emr/get_dks_cert.sh"
- Name: "emr-setup"
  ScriptBootstrapAction:
    Path: "s3://${config_bucket}/scripts/emr/setup.sh"
- Name: "config_hcs"
  ScriptBootstrapAction:
    Path: "s3://${config_bucket}/scripts/emr/config_hcs.sh"
    Args: [
      "${hcs_environment}", 
      "${proxy_http_host}",
      "${proxy_http_port}",
      "${tanium_server_1}",
      "${tanium_server_2}",
      "${tanium_env}",
      "${tanium_port}",
      "${tanium_log_level}",
      "${install_tenable}",
      "${install_trend}",
      "${install_tanium}",
      "${tenantid}",
      "${token}",
      "${policyid}",
      "${tenant}"
    ]
- Name: "replace-rpms-hive"
  ScriptBootstrapAction:
    Path: "s3://${config_bucket}/scripts/emr/replace-rpms-hive.sh"
    Args:
    - "hive"
Steps:
- Name: "hdfs-setup"
  HadoopJarStep:
    Args:
    - "s3://${config_bucket}/scripts/emr/hdfs_setup.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "install-spark-r"
  HadoopJarStep:
    Args:
    - "s3://${config_bucket}/scripts/emr/sparkR_install.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "livy-client-conf"
  HadoopJarStep:
    Args:
    - "s3://${config_bucket}/scripts/emr/livy_client_conf.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "get-scripts"
  HadoopJarStep:
    Args:
    - "s3://${config_bucket}/scripts/emr/get_scripts.sh"
    - "component/uc_repos"
    - "/opt/emr/repos"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
- Name: "create-dbs"
  HadoopJarStep:
    Args:
    - "s3://${config_bucket}/scripts/emr/create_dbs.sh"
    Jar: "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
  ActionOnFailure: "CONTINUE"
