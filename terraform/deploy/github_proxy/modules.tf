module "github_proxy" {
  source = "../../modules/squid_proxy"

  name               = "github-proxy"
  config_bucket      = data.terraform_remote_state.management.outputs.config_bucket
  ecr_dkr_endpoint   = local.ecr_dkr_endpoint
  ecs_cluster        = data.terraform_remote_state.management.outputs.ecs_cluster_main.id
  environment        = local.environment
  log_bucket_id      = data.terraform_remote_state.security_tools.outputs.logstore_bucket.id
  parent_domain_name = local.root_dns_name[local.environment]

  managed_envs_account_numbers = [
    for account_name in local.mgmt_account_mapping[local.environment] :
    local.account[account_name]
  ]

  s3_prefix_list_id    = data.terraform_remote_state.concourse.outputs.s3_prefix_list_id
  subnet_ids           = data.terraform_remote_state.concourse.outputs.subnets_private[*].id
  vpc_id               = data.terraform_remote_state.concourse.outputs.aws_vpc.id
  interface_vpce_sg_id = data.terraform_remote_state.concourse.outputs.interface_vpce_sg_id

  common_tags = local.common_tags
  name_prefix = local.name
}
