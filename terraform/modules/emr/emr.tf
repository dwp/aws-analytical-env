resource "aws_emr_cluster" "cluster" {
  name                              = var.emr_cluster_name
  release_label                     = var.emr_release_label
  applications                      = var.emr_applications
  termination_protection            = var.termination_protection
  keep_job_flow_alive_when_no_steps = var.keep_flow_alive
  security_configuration            = aws_emr_security_configuration.emrfs_em.id
  service_role                      = aws_iam_role.emr_role.arn
  log_uri                           = format("s3n://%s/logs/", var.log_bucket)
  ebs_root_volume_size              = local.ebs_root_volume_size
  autoscaling_role                  = aws_iam_role.emr_autoscaling_role.arn
  tags                              = merge({ "Name" = var.emr_cluster_name, "SSMEnabled" = "True", "ProtectSensitiveData" = "True" }, var.common_tags)
  custom_ami_id                     = var.ami_id

  ec2_attributes {
    subnet_id                         = var.vpc.aws_subnets_private[0].id
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
    instance_type  = local.master_instance_type

    ebs_config {
      size                 = local.ebs_config_size
      type                 = local.ebs_config_type
      iops                 = 0
      volumes_per_instance = local.ebs_config_volumes_per_instance
    }
  }

  core_instance_group {
    name           = "CORE"
    instance_count = local.core_instance_count
    instance_type  = local.core_instance_type

    ebs_config {
      size                 = local.ebs_config_size
      type                 = local.ebs_config_type
      iops                 = 0
      volumes_per_instance = local.ebs_config_volumes_per_instance
    }

    autoscaling_policy = templatefile(format("%s/templates/emr/autoscaling_policy.json", path.module), {
      autoscaling_min_capacity = local.autoscaling_min_capacity,
      autoscaling_max_capacity = local.autoscaling_max_capacity,
    })
  }

  configurations_json = var.use_mysql_hive_metastore == true ? local.configurations_mysql_json : local.configurations_glue_json

  bootstrap_action {
    name = "get-dks-cert"
    path = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.get_dks_cert_sh.key)
  }

  bootstrap_action {
    name = "emr-setup"
    path = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.emr_setup_sh.key)
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


  depends_on = [
    aws_s3_bucket_object.get_dks_cert_sh,
    aws_s3_bucket_object.livy_client_conf_sh,
    aws_s3_bucket_object.hdfs_setup_sh,
  ]

  lifecycle {
    ignore_changes = [
      instance_group,
      ec2_attributes
    ]
  }
}

resource "aws_cloudwatch_event_rule" "cluster_bootstrap_event_rule" {
  name        = "analytical-env-emr-bootstrap-event-rule"
  description = "Alert on failure of EMR to bootstrap"

  event_pattern = <<PATTERN
    {
      "detail": {
        "state": ["TERMINATED_WITH_ERRORS"]
      },
      "source": ["aws.emr"]
    }
    PATTERN
}

resource "aws_cloudwatch_metric_alarm" "emr_terminated_with_errors_alarm" {
  alarm_name          = "EMR Cluster Terminated with Errors (${var.environment})"
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
}
