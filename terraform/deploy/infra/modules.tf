module analytical_env_vpc {
  source  = "dwp/vpc/aws"
  version = "2.0.7"

  common_tags                                = local.common_tags
  gateway_vpce_route_table_ids               = module.networking.outputs.aws_route_table_private_ids
  interface_vpce_source_security_group_count = 0
  interface_vpce_source_security_group_ids   = []
  interface_vpce_subnet_ids                  = module.networking.outputs.aws_subnets_private[*].id
  region                                     = data.aws_region.current.id
  vpc_cidr_block                             = local.cidr_block[local.environment]["aws-analytical-env-vpc"]
  vpc_name                                   = local.name

  dynamodb_endpoint      = true
  ecs_endpoint           = true
  ecs-agent_endpoint     = true
  ecs-telemetry_endpoint = true
  ecrapi_endpoint        = true
  ecrdkr_endpoint        = true
  ec2_endpoint           = true
  ec2messages_endpoint   = true
  glue_endpoint          = true
  kms_endpoint           = true
  logs_endpoint          = true
  monitoring_endpoint    = true
  s3_endpoint            = true
  ssm_endpoint           = true
  ssmmessages_endpoint   = true
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

  vpc_id = module.networking.outputs.aws_vpc

  name_prefix = local.name

  cert_authority_arn = data.terraform_remote_state.aws_certificate_authority.outputs.root_ca.arn
  internal_lb        = false
  parent_domain_name = local.parent_domain_name[local.environment]
  root_dns_prefix    = local.root_dns_prefix[local.environment]
  alb_subnets        = module.networking.outputs.aws_subnets_public.*.id
  common_tags        = local.common_tags

  wafregional_web_acl_id = module.waf.wafregional_web_acl_id
  whitelist_cidr_blocks  = local.whitelist_cidr_blocks

  role_arn = {
    management-dns = "arn:aws:iam::${local.account[local.management_account[local.environment]]}:role/${var.assume_role}"
  }

}
