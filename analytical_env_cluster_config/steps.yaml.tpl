---
BootstrapActions:
- Name: "get-dks-cert"
  ScriptBootstrapAction:
    Path: "s3://${config_bucket}/scripts/emr/get_dks_cert.sh"
- Name: "emr-setup"
  ScriptBootstrapAction:
    Path: "s3://${config_bucket}/scripts/emr/setup.sh"
- Name: "install-r-packages"
  ScriptBootstrapAction:
    Path: "s3://${config_bucket}/scripts/emr/r_packages_install.sh"
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
