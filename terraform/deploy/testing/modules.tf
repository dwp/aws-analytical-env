module "testing" {
  source      = "../../modules/testing"
  name_prefix = local.name
  common_tags = local.common_tags
  environment = local.environment

  log_bucket          = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
  default_ebs_kms_key = data.terraform_remote_state.security-tools.outputs.ebs_cmk.arn

  emr_host_url                  = data.terraform_remote_state.aws_analytical_environment_app.outputs.emr_hostname
  vpc                           = data.terraform_remote_state.aws_analytical_environment_infra.outputs.vpc
  rbac_lambda_file_path         = var.rbac_lambda_file_path
  metrics_lambda_file_path      = var.metrics_lambda_file_path
  test_proxy_user               = var.test_proxy_user
  account                       = local.account[local.environment]
  interface_vpce_sg_id          = data.terraform_remote_state.aws_analytical_environment_infra.outputs.interface_vpce_sg_id
  dataset_s3                    = data.terraform_remote_state.common.outputs.published_bucket
  metrics_data_s3_folder        = var.metrics_data_s3_folder
  published_bucket_cmk          = data.terraform_remote_state.common.outputs.published_bucket_cmk.arn
  s3_prefixlist_id              = data.terraform_remote_state.aws_analytical_environment_infra.outputs.s3_prefix_list_id
  subnets                       = data.terraform_remote_state.aws_analytical_environment_infra.outputs.vpc.aws_subnets_private[*].id
  mgmt_account                  = local.account["management"]
  metrics_data_batch_image_name = "${local.account[local.management_account[local.environment]]}.dkr.ecr.${var.region}.amazonaws.com/aws-analytical-env/create_metrics_data_batch"
  push_host                     = data.terraform_remote_state.aws_analytical_environment_app.outputs.pushgateway.fqdn
  push_host_sg                  = data.terraform_remote_state.aws_analytical_environment_app.outputs.pushgateway.lb_sg.id
  emr_host_sg                   = data.terraform_remote_state.aws_analytical_environment_app.outputs.emr_sg_id

  hcs_environment                      = local.hcs_environment[local.environment]
  cw_metrics_data_agent_namespace      = local.cw_metrics_data_agent_namespace
  cw_metrics_data_agent_log_group_name = local.cw_metrics_data_agent_log_group_name
  asg_autoshutdown                     = local.asg_autoshutdown[local.environment]
  asg_ssmenabled                       = local.asg_ssmenabled[local.environment]
  common_config_bucket                 = data.terraform_remote_state.common.outputs.config_bucket.id
  common_config_bucket_cmk_arn         = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  proxy_host                           = data.terraform_remote_state.aws_analytical_environment_infra.outputs.internet_proxy_dns_name

}
