resource "aws_security_group" "azkaban_pushgateway_vpce_security_group" {
  name        = "azkaban_pushgateway_vpce_security_group"
  description = "Rules necessary for pulling container image"
  vpc_id      = module.analytical_env_vpc.vpc.id
  tags        = merge(local.common_tags, { Name = "azkaban_pushgateway_vpce_security_group" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_inbound_https_from_analytical_env_cidr" {
  description       = "Allow inbound HTTPS traffic from analytical_env_vpc CIDR"
  cidr_blocks       = [module.analytical_env_vpc.vpc.cidr_block]
  type              = "ingress"
  from_port         = 433
  to_port           = 433
  protocol          = "tcp"
  security_group_id = module.analytical_env_vpc.custom_vpce_sg_id
}
