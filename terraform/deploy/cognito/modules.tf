module "cognito" {
  source = "../../modules/cognito"

  common_tags = local.common_tags

  clients = [
    "jupyterhub",
  ]

  root_dns_names = values(local.root_dns_name)

  domain = local.management_account[local.environment] == "management" ? "dataworks" : "dataworks-dev"
}
