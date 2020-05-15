module "cognito" {
  source = "../../modules/cognito"

  common_tags = local.common_tags

  clients = [
    "jupyterhub",
  ]

  root_dns_names  = values(local.root_dns_name)
  domain          = local.cognito_domain
  pre_auth_lambda = data.terraform_remote_state.analytical-frontend-service.outputs.pre_auth_lambda.arn
}

module "cognito-fs" {
  source = "../../modules/cognito-fs"

  common_tags = local.common_tags

  clients = [
    "jupyterhub",
  ]

  root_dns_names = values(local.root_dns_name)

  domain = "${local.management_account[local.environment] == "management" ? "dataworks" : "dataworks-dev"}-fs"
}
