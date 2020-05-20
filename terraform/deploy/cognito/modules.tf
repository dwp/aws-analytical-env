module "cognito-fs" {
  source = "../../modules/cognito-fs"

  common_tags = local.common_tags

  root_dns_names = values(local.root_dns_name)

  domain = "${local.management_account[local.environment] == "management" ? "dataworks" : "dataworks-dev"}-fs"
}
