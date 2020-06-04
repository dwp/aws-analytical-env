module "cognito-fs" {
  source = "../../modules/cognito-fs"

  common_tags = local.common_tags

  root_dns_names = values(local.root_dns_name)
  s3_log_bucket  = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
  domain         = local.cognito_domain

  auth_lambdas = {
    create_auth_challenge          = module.custom-auth-flow.create-auth-challenge-lambda.arn
    define_auth_challenge          = module.custom-auth-flow.define-auth-challenge-lambda.arn
    verify_auth_challenge_response = module.custom-auth-flow.verify-auth-challenge-lambda.arn
    pre_authentication             = module.custom-auth-flow.pre-auth-lambda.arn
    post_authentication            = module.custom-auth-flow.post-auth-lambda.arn
    pre_token_generation           = module.custom-auth-flow.pre-token-generation-lambda.arn
  }
}

module "custom-auth-flow" {
  source = "../../modules/custom-auth-flow"

  name_prefix           = local.name
  region                = var.region
  common_tags           = local.common_tags
  account               = lookup(local.account, local.environment)
  cognito_user_pool_arn = module.cognito-fs.outputs.user_pool_arn
  custom_auth_file_path = var.custom_auth_file_path
}

module "check-user-expiry-lambda" {
  source = "../../modules/check-user-expiry-lambda"

  name_prefix              = var.name_prefix
  common_tags              = local.common_tags
  cognito_user_pool_id     = module.cognito-fs.outputs.user_pool_id
  cognito_user_pool_arn    = module.cognito-fs.outputs.user_pool_arn
  dynamodb_table_user_arn  = module.pre-auth-lambda.dynamodb_table_user.arn
  dynamodb_table_user_name = module.pre-auth-lambda.dynamodb_table_user.name
  from_email_address       = "DataWorks Access Management <access-management@${data.terraform_remote_state.aws_common_infrastructure.outputs.domain_identity}>"
  template_bucket          = data.terraform_remote_state.management.outputs.ses_mailer_bucket.id
}