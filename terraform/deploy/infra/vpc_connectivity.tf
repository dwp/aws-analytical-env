resource "aws_security_group" "azkaban_pushgateway_vpce_security_group" {
  name        = "azkaban_pushgateway_vpce_security_group"
  description = "Rules necessary for pulling container image"
  vpc_id      = module.analytical_env_vpc.vpc.id
  tags        = merge(local.common_tags, { Name = "azkaban_pushgateway_vpce_security_group" })

  lifecycle {
    create_before_destroy = true
  }
}
