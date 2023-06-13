resource "aws_batch_compute_environment" "create_metrics_data_environment" {
  service_role = aws_iam_role.service_role_for_create_metrics_data_batch.arn
  type         = "MANAGED"
  depends_on = [
    aws_iam_role_policy_attachment.create_metrics_data_batch_service_role_attachment
  ]
  compute_environment_name_prefix = "${var.name_prefix}-create-metrics-data-environment-"
  compute_resources {
    instance_role = aws_iam_instance_profile.create_metrics_data_instance_profile.arn
    instance_type = [
      "optimal"
    ]
    min_vcpus     = 0
    desired_vcpus = 0
    max_vcpus     = 8
    security_group_ids = [
      aws_security_group.batch_job_sg.id
    ]
    subnets = [
      var.subnets[0]
    ]
    type = "EC2"

    launch_template {
      launch_template_id = aws_launch_template.create_metrics_data_environment.id
      version            = aws_launch_template.create_metrics_data_environment.latest_version
    }

    tags = merge(
      var.common_tags,
      {
        Name         = "${var.name_prefix}-create-metrics-data-batch-instance",
        Persistence  = "Ignore",
        AutoShutdown = "False",
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "create_metrics_data_environment" {
  name     = "metrics-data-batch"
  image_id = var.ecs_hardened_ami_id

  user_data = base64encode(templatefile("${path.module}/files/batch/userdata.tpl", {
    region                                           = var.region
    name                                             = "metrics-data-batch"
    proxy_port                                       = var.proxy_port
    proxy_host                                       = var.proxy_host
    hcs_environment                                  = var.hcs_environment
    s3_scripts_bucket                                = var.s3_scripts_bucket
    s3_script_logrotate                              = aws_s3_object.batch_logrotate_script.id
    s3_script_cloudwatch_shell                       = aws_s3_object.batch_cloudwatch_script.id
    s3_script_logging_shell                          = aws_s3_object.batch_logging_script.id
    s3_script_config_hcs_shell                       = aws_s3_object.batch_config_hcs.id
    cwa_namespace                                    = var.cw_metrics_data_agent_namespace
    cwa_log_group_name                               = "${var.cw_metrics_data_agent_namespace}-${var.environment}"
    cwa_metrics_collection_interval                  = var.cw_agent_metrics_collection_interval
    cwa_cpu_metrics_collection_interval              = var.cw_agent_cpu_metrics_collection_interval
    cwa_disk_measurement_metrics_collection_interval = var.cw_agent_disk_measurement_metrics_collection_interval
    cwa_disk_io_metrics_collection_interval          = var.cw_agent_disk_io_metrics_collection_interval
    cwa_mem_metrics_collection_interval              = var.cw_agent_mem_metrics_collection_interval
    cwa_netstat_metrics_collection_interval          = var.cw_agent_netstat_metrics_collection_interval
    install_tenable                                  = var.tenable_install
    install_trend                                    = var.trend_install
    install_tanium                                   = var.tanium_install
    tanium_server_1                                  = var.tanium1
    tanium_server_2                                  = var.tanium2
    tanium_env                                       = var.tanium_env
    tanium_port                                      = var.tanium_port_1
    tanium_log_level                                 = var.tanium_log_level
    tenant                                           = var.tenant
    tenantid                                         = var.tenant_id
    token                                            = var.token
    policyid                                         = var.policy_id

  }))

  instance_initiated_shutdown_behavior = "terminate"

  tags = merge(
    var.common_tags,
    {
      Name = "metrics-data-batch"
    }
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
        Name                = "metrics-data-batch",
        AutoShutdown        = var.asg_autoshutdown,
        SSMEnabled          = var.asg_ssmenabled,
        Persistence         = "Ignore",
        propagate_at_launch = true,
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.common_tags,
      {
        Name = "metrics-data-batch",
      }
    )
  }
}

resource "aws_batch_job_queue" "create_metrics_data_job_queue" {
  name     = "${var.name_prefix}-create-metrics-data-job-queue"
  state    = "ENABLED"
  priority = "1"
  compute_environments = [
    aws_batch_compute_environment.create_metrics_data_environment.arn
  ]
}

resource "aws_batch_job_definition" "create_metrics_data_batch_job" {
  name = "${var.name_prefix}-create-metrics-data-batch-job"
  type = "container"

  container_properties = <<CONTAINER_PROPERTIES
    {
        "jobRoleArn": "${aws_iam_role.job_role_for_create_metrics_data_batch.arn}",
        "image": "${var.metrics_data_batch_image_name}",
        "memory": 1500,
        "vcpus": 1,
        "environment": [
            { "name": "path_to_folder", "value" : "${var.name_prefix}-${var.metrics_data_s3_folder}"},
            { "name": "db_name", "value" : "${var.db_name}"},
            { "name": "dataset_s3_name", "value" : "${var.dataset_s3.id}"}
        ]
    }
  CONTAINER_PROPERTIES
}
