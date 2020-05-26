module "cognito-fs" {
  source = "../../modules/cognito-fs"

  common_tags = local.common_tags

  root_dns_names = values(local.root_dns_name)

  domain = "${local.management_account[local.environment] == "management" ? "dataworks" : "dataworks-dev"}-fs"
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

module "pre-auth-lambda" {
  source = "../../modules/pre-auth-lambda"

  name_prefix = local.name
  common_tags = local.common_tags
}
