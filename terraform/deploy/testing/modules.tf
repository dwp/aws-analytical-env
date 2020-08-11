module "testing" {
  source      = "../../modules/testing"
  name_prefix = local.name
  common_tags = local.common_tags
  environment = local.environment

  log_bucket = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id

<<<<<<< HEAD
  emr_host_url             = data.terraform_remote_state.aws_analytical_environment_app.outputs.emr_hostname
  vpc                      = data.terraform_remote_state.aws_analytical_environment_infra.outputs.vpc
  rbac_lambda_file_path    = var.rbac_lambda_file_path
  metrics_lambda_file_path = var.metrics_lambda_file_path
  account                  = local.account[local.environment]
  interface_vpce_sg_id     = data.terraform_remote_state.aws_analytical_environment_infra.outputs.interface_vpce_sg_id
=======
  emr_host_url          = data.terraform_remote_state.aws_analytical_environment_app.outputs.emr_hostname
  vpc                   = data.terraform_remote_state.aws_analytical_environment_infra.outputs.vpc
  rbac_lambda_file_path = var.rbac_lambda_file_path
  account               = local.account[local.environment]

  dataset_s3 = data.terraform_remote_state.aws-analytical-dataset-generation.outputs.published_bucket.name
>>>>>>> adding some tf and a lambda to create and upload false data
}
