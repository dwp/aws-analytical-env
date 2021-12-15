---
BootstrapActions:
- Name: "run-log4j-patch"
  ScriptBootstrapAction:
    Path: "s3://${config_bucket}/scripts/emr/patch-log4j-emr-6.2.1-v1.sh"
- Name: "get-dks-cert"
  ScriptBootstrapAction:
    Path: "s3://${config_bucket}/scripts/emr/get_dks_cert.sh"
- Name: "emr-setup"
  ScriptBootstrapAction:
    Path: "s3://${config_bucket}/scripts/emr/setup.sh"
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
