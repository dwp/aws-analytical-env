module analytical_env_vpc {
  source  = "dwp/vpc/aws"
  version = "3.0.8"

  common_tags                              = local.common_tags
  gateway_vpce_route_table_ids             = module.networking.outputs.aws_route_table_private_ids
  interface_vpce_source_security_group_ids = []
  interface_vpce_subnet_ids                = module.networking.outputs.aws_subnets_private[*].id
  region                                   = data.aws_region.current.id
  vpc_cidr_block                           = local.cidr_block[local.environment]["aws-analytical-env-vpc"]
  vpc_name                                 = local.name

  aws_vpce_services = [
    "dynamodb",
    "ecs",
    "ecs-agent",
    "ecs-telemetry",
    "ecr.api",
    "ecr.dkr",
    "ec2",
    "ec2messages",
    "glue",
    "kms",
    "logs",
    "monitoring",
    "s3",
    "sns",
    "ssm",
    "ssmmessages",
    "git-codecommit",
    "sts",
    "secretsmanager",
    "sns"
  ]

  custom_vpce_services = [
    {
      key          = "proxy_vpc_endpoint"
      service_name = data.terraform_remote_state.internet_egress.outputs.internet_proxy_service.service_name
      port         = 3128
    },
    {
      key          = "github_proxy_vpc_endpoint"
      service_name = data.terraform_remote_state.analytical_env_github_proxy.outputs.proxy_vpce_service.service_name
      port         = 3128
    }
  ]
}

module networking {
  source = "../../modules/networking"

  common_tags = local.common_tags
  name        = local.name

  role_arn = {
    management-crypto          = "arn:aws:iam::${local.account[local.management_account[local.environment]]}:role/${var.assume_role}"
    management-internet-egress = "arn:aws:iam::${local.account[local.management_account[local.environment]]}:role/${var.assume_role}"
  }

  vpc = {
    cidr_block          = module.analytical_env_vpc.vpc.cidr_block
    id                  = module.analytical_env_vpc.vpc.id
    main_route_table_id = module.analytical_env_vpc.vpc.main_route_table_id
  }

  crypto_vpc          = data.terraform_remote_state.crypto.outputs.crypto_vpc
  crypto_vpc_owner_id = local.account[local.management_account[local.environment]]
  dks_subnet          = data.terraform_remote_state.crypto.outputs.dks_subnet
  dks_route_table     = data.terraform_remote_state.crypto.outputs.dks_route_table
  region              = var.region
}

module waf {
  source = "../../modules/waf"

  name       = local.name
  log_bucket = data.terraform_remote_state.security-tools.outputs.logstore_bucket.arn

  whitelist_cidr_blocks = local.whitelist_cidr_blocks
  common_tags           = local.common_tags
  name_prefix           = local.name
}

module alb {
  source = "../../modules/alb"

  vpc_id = module.networking.outputs.aws_vpc.id

  name_prefix = local.name
  region      = var.region

  cert_authority_arn = data.terraform_remote_state.aws_certificate_authority.outputs.root_ca.arn
  internal_lb        = false
  parent_domain_name = local.parent_domain_name[local.environment]
  root_dns_name      = local.root_dns_name[local.environment]
  alb_subnets        = module.networking.outputs.aws_subnets_public.*.id
  common_tags        = local.common_tags
  logging_bucket     = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id

  wafregional_web_acl_id = module.waf.wafregional_web_acl_id
  whitelist_cidr_blocks  = local.whitelist_cidr_blocks

  role_arn = {
    management-dns = "arn:aws:iam::${local.account[local.management_account[local.environment]]}:role/${var.assume_role}"
  }

}
