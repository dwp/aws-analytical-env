resource "aws_emr_cluster" "cluster" {
  name                              = var.emr_cluster_name
  release_label                     = var.emr_release_label
  applications                      = var.emr_applications
  termination_protection            = var.termination_protection
  keep_job_flow_alive_when_no_steps = var.keep_flow_alive
  security_configuration            = aws_emr_security_configuration.analytical_env_emrfs_em.id
  service_role                      = aws_iam_role.emr_role.arn
  log_uri                           = format("s3n://%s/logs/", var.log_bucket)
  ebs_root_volume_size              = local.ebs_root_volume_size
  autoscaling_role                  = aws_iam_role.emr_autoscaling_role.arn
  tags                              = merge({ "Name" = var.emr_cluster_name, "SSMEnabled" = "True", "ProtectSensitiveData" = "True" }, var.common_tags)
  custom_ami_id                     = var.ami_id

  ec2_attributes {
    subnet_id                         = local.emr_cluster_subnet_id
    additional_master_security_groups = aws_security_group.emr.id
    additional_slave_security_groups  = aws_security_group.emr.id
    emr_managed_master_security_group = aws_security_group.emr_master_private.id
    emr_managed_slave_security_group  = aws_security_group.emr_slave_private.id
    service_access_security_group     = aws_security_group.emr_service_access.id
    instance_profile                  = aws_iam_instance_profile.emr_ec2_role.arn
  }

  master_instance_group {
    name           = "MASTER"
    instance_count = 1
    instance_type  = local.master_instance_type[var.environment]

    ebs_config {
      size                 = local.ebs_config_size
      type                 = local.ebs_config_type
      iops                 = 0
      volumes_per_instance = local.ebs_config_volumes_per_instance
    }
  }

  core_instance_group {
    name           = "CORE"
    instance_count = local.core_instance_count[var.environment]
    instance_type  = local.core_instance_type[var.environment]

    ebs_config {
      size                 = local.ebs_config_size
      type                 = local.ebs_config_type
      iops                 = 0
      volumes_per_instance = local.ebs_config_volumes_per_instance
    }

    autoscaling_policy = templatefile(format("%s/templates/emr/autoscaling_policy.json", path.module), {
      autoscaling_min_capacity = local.autoscaling_min_capacity[var.environment],
      autoscaling_max_capacity = local.autoscaling_max_capacity[var.environment],
      cooldown_scale_out       = 120,
      cooldown_scale_in        = 60 * 30 // Half an hour
    })
  }

  configurations_json = var.use_mysql_hive_metastore == true ? local.configurations_mysql_json : local.configurations_glue_json

  bootstrap_action {
    name = "run-log4j-patch"
    path = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.patch_log4j_emr_sh.key)
  }

  bootstrap_action {
    path = "file:/bin/echo"
    name = "Dummy bootstrap action to track the md5 hash of the configuration json and redeploy only when changed"
    args = [md5(var.use_mysql_hive_metastore == true ? local.configurations_mysql_json : local.configurations_glue_json)]
  }

  bootstrap_action {
    name = "get-dks-cert"
    path = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.get_dks_cert_sh.key)
  }

  bootstrap_action {
    name = "emr-setup"
    path = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.emr_setup_sh.key)
  }

  bootstrap_action {
    name = "config-hcs"
    path = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.config_hcs_sh.key)
    args = [local.hcs_environment[local.environment], var.internet_proxy_dns_name, var.proxy_port]
  }

  bootstrap_action {
    name = "python-packages-install"
    path = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.py_pckgs_install.key)
  }

  bootstrap_action {
    name = "replace-rpms-hive"
    path = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.replace_rpms_hive_sh.key)
    args = ["hive"]
  }

  step {
    name              = "hdfs-setup"
    action_on_failure = "CONTINUE"
    hadoop_jar_step {
      jar = "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
      args = [
        format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.hdfs_setup_sh.key)
      ]
    }
  }

  step {
    name              = "Install SparkR on Master"
    action_on_failure = "CONTINUE"

    hadoop_jar_step {
      jar = "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
      args = [
        format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.sparkR_install.key)
      ]
    }
  }

  step {
    name              = "livy-client-conf"
    action_on_failure = "CONTINUE"
    hadoop_jar_step {
      jar = "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
      args = [
        format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.livy_client_conf_sh.key)
      ]
    }
  }

  step {
    name              = "hive-auth-conf"
    action_on_failure = "CONTINUE"
    hadoop_jar_step {
      jar = "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
      args = [
        format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.hive_auth_conf_sh.key)
      ]
    }
  }

  step {
    name              = "get-scripts"
    action_on_failure = "CONTINUE"
    hadoop_jar_step {
      jar = "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
      args = [
        format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.get_scripts_sh.key), "component/uc_repos", "/opt/emr/repos"
      ]
    }
  }

  step {
    name              = "create-dbs"
    action_on_failure = "CONTINUE"
    hadoop_jar_step {
      jar = "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
      args = [
        format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.create_dbs_sh.key)
      ]
    }
  }

  depends_on = [
    aws_s3_bucket_object.get_dks_cert_sh,
    aws_s3_bucket_object.livy_client_conf_sh,
    aws_s3_bucket_object.hdfs_setup_sh,
    aws_emr_security_configuration.analytical_env_emrfs_em,
  ]

  lifecycle {
    ignore_changes = [
      ec2_attributes, configurations_json
    ]
  }
}

resource "aws_cloudwatch_event_rule" "cluster_bootstrap_event_rule" {
  name        = "analytical-env-emr-bootstrap-event-rule"
  description = "Alert on failure of EMR to bootstrap"

  event_pattern = <<PATTERN
    {
      "detail": {
        "state": ["TERMINATED_WITH_ERRORS"],
        "name": ["${aws_emr_cluster.cluster.name}"]
      },
      "source": ["aws.emr"]
    }
    PATTERN
  tags          = merge(var.common_tags, { Name : "${var.name_prefix}-emr-error-rule" })
}

resource "aws_cloudwatch_metric_alarm" "emr_terminated_with_errors_alarm" {
  alarm_name          = "${var.emr_cluster_name} EMR Cluster Terminated with Errors (${var.environment})"
  statistic           = "Sum"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "1"
  metric_name         = "TriggeredRules"
  namespace           = "AWS/Events"
  evaluation_periods  = "1"
  period              = "60"
  alarm_actions       = [var.monitoring_sns_topic_arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.cluster_bootstrap_event_rule.name
  }
  alarm_description         = "This metric monitors invocations of the analytical-env-emr-bootstrap-event-rule"
  insufficient_data_actions = []
  tags                      = merge(var.common_tags, { Name : "${var.name_prefix}-with-errors-alarm" })
}

resource "aws_cloudwatch_log_group" "analytical_batch_get_scripts_logs" {
  name              = local.cw_agent_log_group_name
  retention_in_days = 180
  tags              = merge(var.common_tags, { Name : "${var.name_prefix}-get-scripts-logs" })
}

resource "aws_cloudwatch_log_group" "analytical_batch_step_logs" {
  name              = local.cw_agent_step_log_group_name
  retention_in_days = 180
  tags              = merge(var.common_tags, { Name : "${var.name_prefix}-get-step-logs" })
}

resource "aws_cloudwatch_log_group" "batch_si_step_logs" {
  name              = local.cw_agent_si_step_log_group_name
  retention_in_days = 180
  tags              = merge(var.common_tags, { Name : "${var.name_prefix}-get-step-logs" })
}