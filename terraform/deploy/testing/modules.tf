module "testing" {
  source      = "../../modules/testing"
  name_prefix = local.name
  common_tags = local.common_tags
  environment = local.environment

  log_bucket = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id

  emr_host_url          = data.terraform_remote_state.aws_analytical_environment_app.outputs.emr_hostname
  vpc                   = data.terraform_remote_state.aws_analytical_environment_infra.outputs.vpc
  rbac_lambda_file_path = var.rbac_lambda_file_path
  account               = local.account[local.environment]
}
