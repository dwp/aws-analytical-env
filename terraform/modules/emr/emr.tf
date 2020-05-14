resource "aws_emr_cluster" "cluster" {
  name                              = var.emr_cluster_name
  release_label                     = var.emr_release_label
  applications                      = var.emr_applications
  termination_protection            = var.termination_protection
  keep_job_flow_alive_when_no_steps = var.keep_flow_alive
  security_configuration            = aws_emr_security_configuration.emrfs_em.id
  service_role                      = aws_iam_role.emr_role.arn
  log_uri                           = format("s3n://%s/logs/", aws_s3_bucket.emr.id)
  ebs_root_volume_size              = local.ebs_root_volume_size
  autoscaling_role                  = aws_iam_role.emr_autoscaling_role.arn
  tags                              = merge({ "Name" = var.emr_cluster_name, "SSMEnabled" = "True" }, var.common_tags)
  custom_ami_id                     = var.ami_id

  ec2_attributes {
    subnet_id                         = var.vpc.aws_subnets_private[0].id
    additional_master_security_groups = aws_security_group.emr.id
    additional_slave_security_groups  = aws_security_group.emr.id
    instance_profile                  = aws_iam_instance_profile.emr_ec2_role.arn
  }

  master_instance_group {
    name           = "MASTER"
    instance_count = 1
    instance_type  = local.master_instance_type
    # bid_price      = local.master_bid_price

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
    # bid_price      = local.core_bid_price

    ebs_config {
      size                 = local.ebs_config_size
      type                 = local.ebs_config_type
      iops                 = 0
      volumes_per_instance = local.ebs_config_volumes_per_instance
    }
  }

  configurations_json = templatefile(format("%s/templates/emr/configuration.json", path.module), {
    logs_bucket_path     = format("s3://%s/logs", aws_s3_bucket.emr.id)
    data_bucket_path     = format("s3://%s/data", aws_s3_bucket.emr.id)
    notebook_bucket_path = format("%s/data", aws_s3_bucket.emr.id)
    proxy_host           = var.internet_proxy["dns_name"]
    full_no_proxy        = join("|", local.no_proxy_hosts)
  })

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
    action_on_failure = "TERMINATE_CLUSTER"
    hadoop_jar_step {
      jar = "s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar"
      args = [
        format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.hdfs_setup_sh.key)
      ]
    }
  }

  step {
    name              = "livy-client-conf"
    action_on_failure = "TERMINATE_CLUSTER"
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

//resource "aws_emr_instance_group" "task" {
//  name           = "TASK"
//  cluster_id     = aws_emr_cluster.cluster.id
//  instance_count = 0
//  instance_type  = local.task_instance_type
//  # bid_price      = local.task_bid_price
//  ebs_optimized = false
//
//  autoscaling_policy = templatefile(format("%s/files/emr/autoscaling_policy.json", path.module), {
//    autoscaling_min_capacity = local.autoscaling_min_capacity,
//    autoscaling_max_capacity = local.autoscaling_max_capacity,
//  })
//
//  ebs_config {
//    size                 = local.ebs_config_size
//    type                 = local.ebs_config_type
//    iops                 = 0
//    volumes_per_instance = local.ebs_config_volumes_per_instance
//  }
//}
