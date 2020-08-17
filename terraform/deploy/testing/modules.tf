module "testing" {
  source      = "../../modules/testing"
  name_prefix = local.name
  common_tags = local.common_tags
  environment = local.environment

  log_bucket = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id

  emr_host_url                  = data.terraform_remote_state.aws_analytical_environment_app.outputs.emr_hostname
  vpc                           = data.terraform_remote_state.aws_analytical_environment_infra.outputs.vpc
  rbac_lambda_file_path         = var.rbac_lambda_file_path
  metrics_lambda_file_path      = var.metrics_lambda_file_path
  account                       = local.account[local.environment]
  interface_vpce_sg_id          = data.terraform_remote_state.aws_analytical_environment_infra.outputs.interface_vpce_sg_id
  dataset_s3                    = data.terraform_remote_state.aws-analytical-dataset-generation.outputs.published_bucket
  create_metrics_data_file_path = var.create_metrics_data_file_path
  published_bucket_cmk          = data.terraform_remote_state.aws-analytical-dataset-generation.outputs.published_bucket_cmk.arn
  s3_prefixlist_id              = data.terraform_remote_state.aws_analytical_environment_infra.outputs.s3_prefix_list_id
  subnets                       = data.terraform_remote_state.aws_analytical_environment_infra.outputs.vpc.aws_subnets_private[*].id
  mgmt_account                  = local.account["management"]
}
