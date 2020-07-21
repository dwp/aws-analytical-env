module analytical_env_vpc {
  source  = "dwp/vpc/aws"
  version = "3.0.3"

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
    "ssm",
    "ssmmessages",
    "git-codecommit"
  ]

  custom_vpce_services = [
    {
      key          = "proxy_vpc_endpoint"
      service_name = data.terraform_remote_state.internet_egress.outputs.internet_proxy_service.service_name
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

  crypto_vpc                        = data.terraform_remote_state.crypto.outputs.crypto_vpc
  crypto_vpc_owner_id               = local.account[local.management_account[local.environment]]
  dks_subnet                        = data.terraform_remote_state.crypto.outputs.dks_subnet
  dks_route_table                   = data.terraform_remote_state.crypto.outputs.dks_route_table
  internet_egress_proxy_route_table = data.terraform_remote_state.internet_egress.outputs.proxy_route_table
  internet_egress_proxy_subnet      = data.terraform_remote_state.internet_egress.outputs.proxy_subnet
  internet_transit_gateway          = data.terraform_remote_state.internet_egress.outputs.internet_transit_gateway
  tgw_attachment_internet_egress    = data.terraform_remote_state.internet_egress.outputs.tgw_attachment_internet_egress
  tgw_rtb_internet_egress           = data.terraform_remote_state.internet_egress.outputs.tgw_rtb_internet_egress
  proxy_route_table                 = data.terraform_remote_state.internet_egress.outputs.proxy_route_table
  proxy_subnet                      = data.terraform_remote_state.internet_egress.outputs.proxy_subnet
  region                            = var.region
}

module waf {
  source = "../../modules/waf"

  name       = local.name
  log_bucket = data.terraform_remote_state.security-tools.outputs.logstore_bucket.arn

  whitelist_cidr_blocks = local.whitelist_cidr_blocks

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

  wafregional_web_acl_id = module.waf.wafregional_web_acl_id
  whitelist_cidr_blocks  = local.whitelist_cidr_blocks

  role_arn = {
    management-dns = "arn:aws:iam::${local.account[local.management_account[local.environment]]}:role/${var.assume_role}"
  }

}
