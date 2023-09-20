resource "aws_s3_bucket_object" "get_dks_cert_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/get_dks_cert.sh"
  content = data.template_file.get_dks_cert_sh.rendered
  tags    = merge(var.common_tags, { Name : "${var.name_prefix}-get-dks" })
}

data "template_file" "get_dks_cert_sh" {
  template = file(format("%s/templates/emr/get_dks_cert.sh", path.module))
  vars = {
    emr_bucket_path    = aws_s3_bucket.emr.id
    acm_cert_arn       = aws_acm_certificate.emr.arn
    private_key_alias  = "development"
    truststore_aliases = var.truststore_aliases
    truststore_certs   = var.truststore_certs
    full_proxy         = local.full_proxy
    full_no_proxy      = join(",", local.no_proxy_hosts)
    dks_endpoint       = var.dks_endpoint
    name               = var.emr_cluster_name
  }
}

resource "aws_s3_bucket_object" "emr_setup_sh" {
  depends_on = [aws_s3_bucket.hive_data, aws_s3_bucket_object.hive_data_bucket_group_folders]
  bucket     = aws_s3_bucket.emr.id
  key        = "scripts/emr/setup.sh"
  content    = data.template_file.emr_setup_sh.rendered
  tags       = merge(var.common_tags, { Name : "${var.name_prefix}-emr-setup" })
}

data "template_file" "emr_setup_sh" {
  template = file(format("%s/templates/emr/setup.sh", path.module))
  vars = {
    aws_default_region              = data.aws_region.current.name
    full_proxy                      = local.full_proxy
    full_no_proxy                   = join(",", local.no_proxy_hosts)
    cognito_role_arn                = aws_iam_role.cogntio_read_only_role.arn
    user_pool_id                    = var.cognito_user_pool_id
    azkaban_notifications_shell     = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_notifications_sh.key)
    azkaban_metrics_shell           = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_metrics_sh.key)
    delete_azkaban_metrics_shell    = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.delete_azkaban_metrics_sh.key)
    sft_utility_shell               = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.sft_utility_sh.key)
    logging_shell                   = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.logging_sh.key)
    cloudwatch_shell                = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.cloudwatch_sh.key)
    get_scripts_shell               = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.get_scripts_sh.key)
    poll_status_table_shell         = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.poll_status_table_sh.key)
    trigger_tagger_shell            = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.trigger_s3_tagger_batch_job_sh.key)
    parallel_shell                  = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.parallel_sh.key)
    patch_log4j_emr_shell           = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.patch_log4j_emr_sh.key)
    config_hcs_shell                = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.config_hcs_sh.key)
    cwa_namespace                   = local.cw_agent_namespace
    cwa_log_group_name              = local.cw_agent_step_log_group_name
    cwa_si_namespace                = local.cw_agent_si_namespace
    cwa_si_log_group_name           = local.cw_agent_si_step_log_group_name
    config_bucket                   = var.config_bucket_id
    aws_default_region              = "eu-west-2"
    cwa_metrics_collection_interval = local.cw_agent_metrics_collection_interval
    publish_bucket_id               = var.dataset_s3.id
    compaction_bucket_id            = var.compaction_bucket.id
    hcs_environment                 = local.hcs_environment[local.environment]
    http_proxy_host                 = var.internet_proxy_dns_name
    http_proxy_port                 = var.proxy_port
    install_tenable                 = var.tenable_install
    install_trend                   = var.trend_install
    install_tanium                  = var.tanium_install
    tanium_server_1                 = var.tanium1
    tanium_server_2                 = var.tanium2
    tanium_env                      = var.tanium_env
    tanium_port                     = var.tanium_port_1
    tanium_log_level                = var.tanium_log_level
    tenant                          = var.tenant
    tenantid                        = var.tenant_id
    token                           = var.token
    policyid                        = var.policy_id
    tanium_vpce_sg                  = var.tanium_vpce_sg

    azkaban_chunk_environment_sh    = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_chunk_environment.key)
    azkaban_metadata_environment_sh = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_metadata_environment.key)
    azkaban_control_environment_sh  = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_control_environment.key)
    azkaban_enqueue_environment_sh  = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_enqueue_environment.key)
    azkaban_egress_environment_sh   = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_egress_environment.key)

    azkaban_chunk_run_sh    = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_chunk_run.key)
    azkaban_metadata_run_sh = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_metadata_run.key)
    azkaban_control_run_sh  = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_control_run.key)
    azkaban_enqueue_run_sh  = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_enqueue_run.key)
    azkaban_egress_run_sh   = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_egress_run.key)

    azkaban_common_aws_sh         = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_common_aws.key)
    azkaban_common_console_sh     = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_common_console.key)
    azkaban_common_fs_sh          = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_common_fs.key)
    azkaban_common_environment_sh = format("s3://%s/%s", aws_s3_bucket.emr.id, aws_s3_bucket_object.azkaban_common_environment.key)
  }
}

resource "aws_s3_bucket_object" "trigger_s3_tagger_batch_job_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/trigger_s3_tagger_batch_job.sh"
  content = data.template_file.trigger_s3_tagger_batch_job_sh.rendered
  tags    = merge(var.common_tags, { Name : "${var.name_prefix}-trigger-tagger" })
}

data "template_file" "trigger_s3_tagger_batch_job_sh" {
  template = file(format("%s/templates/emr/trigger_s3_tagger_batch_job.sh", path.module))
  vars = {
    full_proxy          = local.full_proxy
    config_bucket       = var.config_bucket_id
    job_definition_name = var.s3_tagger_job_definition_name
  }
}

resource "aws_s3_bucket_object" "hdfs_setup_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/hdfs_setup.sh"
  content = data.template_file.hdfs_setup_sh.rendered
  tags    = merge(var.common_tags, { Name : "${var.name_prefix}-hdfs-setup" })
}

data "template_file" "hdfs_setup_sh" {
  template = file(format("%s/templates/emr/hdfs_setup.sh", path.module))
  vars = {
    hive_data_s3     = aws_s3_bucket.hive_data.arn
    config_bucket    = var.config_bucket_id
    published_bucket = var.dataset_s3.id
    hive_heapsize    = var.hive_heapsize
  }
}

resource "aws_s3_bucket_object" "livy_client_conf_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/livy_client_conf.sh"
  content = data.template_file.livy_client_conf_sh.rendered
  tags    = merge(var.common_tags, { Name : "${var.name_prefix}-livy-config" })
}


# A shell script to update R and install required R packages
resource "aws_s3_bucket_object" "r_packages_install" {
  bucket = aws_s3_bucket.emr.id
  key    = "scripts/emr/r_packages_install.sh"
  content = templatefile("${path.module}/templates/emr/r_packages_install.sh", {
    full_proxy    = local.full_proxy,
    full_no_proxy = join(",", local.no_proxy_hosts),
    packages      = join(";", concat(local.r_dependencies, local.r_packages))
    r_version     = local.r_version
  })
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-r-install" })
}

resource "aws_s3_bucket_object" "sparkR_install" {
  bucket = aws_s3_bucket.emr.id
  key    = "scripts/emr/sparkR_install.sh"
  content = templatefile("${path.module}/templates/emr/sparkR_install.sh", {
    full_proxy    = local.full_proxy,
    full_no_proxy = join(",", local.no_proxy_hosts),
    r_version     = local.r_version
  })
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-sparkR-install" })
}

resource "aws_s3_bucket_object" "py_pckgs_install" {
  bucket = aws_s3_bucket.emr.id
  key    = "scripts/emr/py_pckgs_install.sh"
  content = templatefile("${path.module}/templates/emr/py_pckgs_install.sh", {
    full_proxy    = local.full_proxy,
    full_no_proxy = join(",", local.no_proxy_hosts),
  })
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-py-pckgs-install" })
}

data "template_file" "livy_client_conf_sh" {
  template = file(format("%s/templates/emr/livy_client_conf.sh", path.module))
  vars = {
    livy_client_http_connection_socket_timeout = "5m"
    livy_client_http_connection_timeout        = "30s"
    livy_rsc_client_connect_timeout            = "120s"
    livy_rsc_client_shutdown_timeout           = "10s"
    livy_rsc_job_cancel_timeout                = "600s"
    livy_rsc_job_cancel_trigger_interval       = "500ms"
    livy_rsc_retained_statements               = "200"
    livy_rsc_server_connect_timeout            = "360s"
  }
}

resource "aws_s3_bucket_object" "logging_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/logging.sh"
  content = file("${path.module}/templates/emr/logging.sh")

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-logging-sh" })
}

resource "aws_s3_bucket_object" "get_scripts_sh" {
  bucket = aws_s3_bucket.emr.id
  key    = "scripts/emr/get_scripts.sh"
  content = templatefile("${path.module}/templates/emr/get_scripts.sh",
    {
      config_bucket = format("s3://%s", var.config_bucket_id)
    }
  )

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-get-scripts-sh" })
}

resource "aws_s3_bucket_object" "parallel_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/parallel.sh"
  content = file("${path.module}/templates/emr/parallel.sh")

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-parallel-sh" })
}

resource "aws_s3_bucket_object" "cloudwatch_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/cloudwatch.sh"
  content = file("${path.module}/templates/emr/cloudwatch.sh")

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-cw-sh" })
}

resource "aws_s3_bucket_object" "config_hcs_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/config_hcs.sh"
  content = file("${path.module}/templates/emr/config_hcs.sh")

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-config-hcs-sh" })
}

resource "aws_s3_bucket_object" "create_dbs_sh" {
  bucket = aws_s3_bucket.emr.id
  key    = "scripts/emr/create_dbs.sh"
  content = templatefile("${path.module}/templates/emr/create_dbs.sh",
    {
      processed_bucket = format("s3://%s", var.processed_bucket_id)
      published_bucket = format("s3://%s", var.dataset_s3.id)
    }
  )
  tags = merge(var.common_tags, { Name = "${var.name_prefix}-create-dbs-sh" })
}

resource "aws_s3_bucket_object" "check_status_sh" {
  bucket  = var.config_bucket_id
  key     = "component/uc_repos/status_check/check_status.sh"
  content = file("${path.module}/templates/emr/check_status.sh")

  tags = merge(var.common_tags, { Name = "${var.name_prefix}check-status-sh" })
}

resource "aws_s3_bucket_object" "update_dynamo_sh" {
  bucket  = var.config_bucket_id
  key     = "component/uc_repos/status_check/update_dynamo.sh"
  content = file("${path.module}/templates/emr/update_dynamo.sh")

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-update-dynamo-sh"
  })
}

resource "aws_s3_bucket_object" "poll_status_table_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/poll_status_table.sh"
  content = file("${path.module}/templates/emr/poll_status_table.sh")

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-poll-status-table-sh" })
}

resource "aws_s3_bucket_object" "patch_log4j_emr_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/patch-log4j-emr-6.3.1-v2.sh"
  content = file("${path.module}/templates/emr/patch-log4j-emr-6.3.1-v2.sh")

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-patch-log4j-emr-sh" })
}

resource "aws_s3_bucket_object" "replace_rpms_hive_sh" {
  bucket = aws_s3_bucket.emr.id
  key    = "scripts/emr/replace-rpms-hive.sh"
  content = templatefile("${path.module}/templates/emr/replace-rpms-hive.sh",
    {
      hive_scratch_dir_s3_prefix = var.hive_scratch_dir_s3
    }
  )

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-replace-rpms-hive-sh" })
}


resource "aws_s3_bucket_object" "azkaban_notifications_sh" {
  bucket = aws_s3_bucket.emr.id
  key    = "scripts/emr/azkaban_notifications.sh"
  content = templatefile("${path.module}/templates/emr/azkaban_notifications.sh",
    {
      monitoring_topic_arn = var.monitoring_sns_topic_arn,
      aws_region           = var.region
    }
  )

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-azkaban-notifications-sh" })
}

resource "aws_s3_bucket_object" "azkaban_metrics_sh" {
  bucket = aws_s3_bucket.emr.id
  key    = "scripts/emr/azkaban_metrics.sh"
  content = templatefile("${path.module}/templates/emr/azkaban_metrics.sh",
    {
      azkaban_pushgateway_hostname = var.azkaban_pushgateway_hostname
    }
  )
  tags = merge(var.common_tags, { Name = "${var.name_prefix}-azkaban-notifications-sh" })
}

resource "aws_s3_bucket_object" "delete_azkaban_metrics_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/delete_azkaban_metrics.sh"
  content = file("${path.module}/templates/emr/delete_azkaban_metrics.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-azkaban-notifications-sh" })
}

resource "aws_s3_bucket_object" "sft_utility_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/sft_utility.sh"
  content = file("${path.module}/templates/emr/sft_utility.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-sft-utility-sh" })
}

data "template_file" "hive_auth_conf_sh" {
  template = file(format("%s/templates/emr/hive_auth_conf.sh", path.module))
  vars = {
    aws_region                = var.region
    user_pool_id              = var.cognito_user_pool_id
    full_proxy                = local.full_proxy
    full_no_proxy             = join(",", local.no_proxy_hosts)
    hive_auth_provider_s3_uri = "s3://${aws_s3_bucket_object.hive_auth_provider_jar.bucket}/${aws_s3_bucket_object.hive_auth_provider_jar.key}"
  }
}

resource "aws_s3_bucket_object" "hive_auth_conf_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/hive_auth_conf.sh"
  content = data.template_file.hive_auth_conf_sh.rendered

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-hive-auth-conf-sh" })
}

resource "aws_s3_bucket_object" "azkaban_chunk_environment" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/azkaban/chunk/environment.sh"
  content = file("${path.module}/files/azkaban/chunk/environment.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-chunk-environment-sh" })
}

resource "aws_s3_bucket_object" "azkaban_control_environment" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/azkaban/control/environment.sh"
  content = file("${path.module}/files/azkaban/control/environment.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-control-environment-sh" })
}

resource "aws_s3_bucket_object" "azkaban_egress_environment" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/azkaban/egress/environment.sh"
  content = file("${path.module}/files/azkaban/egress/environment.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-egress-environment-sh" })
}

resource "aws_s3_bucket_object" "azkaban_enqueue_environment" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/azkaban/enqueue/environment.sh"
  content = file("${path.module}/files/azkaban/enqueue/environment.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-enqueue-environment-sh" })
}

resource "aws_s3_bucket_object" "azkaban_metadata_environment" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/azkaban/metadata/environment.sh"
  content = file("${path.module}/files/azkaban/metadata/environment.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-metadata-environment-sh" })
}

resource "aws_s3_bucket_object" "azkaban_chunk_run" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/azkaban/chunk/run.sh"
  content = file("${path.module}/files/azkaban/chunk/run.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-chunk-run-sh" })
}

resource "aws_s3_bucket_object" "azkaban_egress_run" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/azkaban/egress/run.sh"
  content = file("${path.module}/files/azkaban/egress/run.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-egress-run-sh" })
}

resource "aws_s3_bucket_object" "azkaban_enqueue_run" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/azkaban/enqueue/run.sh"
  content = file("${path.module}/files/azkaban/enqueue/run.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-enqueue-run-sh" })
}

resource "aws_s3_bucket_object" "azkaban_metadata_run" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/azkaban/metadata/run.sh"
  content = file("${path.module}/files/azkaban/metadata/run.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-metadata-run-sh" })
}

resource "aws_s3_bucket_object" "azkaban_control_run" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/azkaban/control/run.sh"
  content = file("${path.module}/files/azkaban/control/run.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-control-run-sh" })
}

resource "aws_s3_bucket_object" "azkaban_common_aws" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/azkaban/common/aws.sh"
  content = file("${path.module}/files/azkaban/common/aws.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-common-aws-sh" })
}

resource "aws_s3_bucket_object" "azkaban_common_console" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/azkaban/common/console.sh"
  content = file("${path.module}/files/azkaban/common/console.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-common-console-sh" })
}

resource "aws_s3_bucket_object" "azkaban_common_fs" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/azkaban/common/fs.sh"
  content = file("${path.module}/files/azkaban/common/fs.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-common-fs-sh" })
}

resource "aws_s3_bucket_object" "azkaban_common_environment" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/azkaban/common/environment.sh"
  content = file("${path.module}/files/azkaban/common/environment.sh")
  tags    = merge(var.common_tags, { Name = "${var.name_prefix}-common-environment-sh" })
}
