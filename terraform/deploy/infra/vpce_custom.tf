# VPCE should only be created here if their configuration is not supported by module.analytical_env_vpc.custom_vpce_services

# Permits internal connectivity between analytical-env and AP frontend
resource "aws_vpc_endpoint" "ap_frontend_vpce" {
  vpc_id              = module.analytical_env_vpc.vpc.id
  service_name        = local.frontend_custom_vpce
  private_dns_enabled = true
  security_group_ids  = [module.analytical_env_vpc.interface_vpce_sg_id]
  subnet_ids          = module.networking.outputs.aws_subnets_private[*].id
  vpc_endpoint_type   = "Interface"
}
