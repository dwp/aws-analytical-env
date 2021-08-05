resource "aws_security_group_rule" "allow_metrics_to_vpce_traffic_ingress" {
  description              = "Accept VPCE traffic to metrics"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  security_group_id        = module.analytical_env_vpc.interface_vpce_sg_id
  source_security_group_id = aws_security_group.azkaban_pushgateway_vpce_security_group.id
}

resource "aws_security_group_rule" "allow_metrics_to_vpce_traffic_egress" {
  description              = "Allow outbound requests to VPC endpoints from metrics"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  security_group_id        = aws_security_group.azkaban_pushgateway_vpce_security_group.id
  source_security_group_id = module.analytical_env_vpc.interface_vpce_sg_id
}
