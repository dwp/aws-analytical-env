resource "aws_security_group" "internet_proxy" {
  name   = var.name
  vpc_id = var.vpc_id
  tags   = merge(var.common_tags, { Name : "${var.name_prefix}-internet-proxy" })
}

resource "aws_security_group_rule" "internet_proxy" {
  description       = "Internet proxy users"
  type              = "ingress"
  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  protocol          = "tcp"
  from_port         = var.proxy_port
  to_port           = var.proxy_port
  security_group_id = aws_security_group.internet_proxy.id
}

resource "aws_security_group_rule" "ecs_to_s3" {
  description       = "Allow ECS to reach S3 (for Docker pull from ECR)"
  type              = "egress"
  prefix_list_ids   = [var.s3_prefix_list_id]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.internet_proxy.id
}

resource "aws_security_group_rule" "proxy_to_uc_github_https" {
  description       = "Allow Internet Proxy to reach all Internet hosts (HTTPS)"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.internet_proxy.id
}

resource "aws_security_group_rule" "proxy_to_uc_github_http" {
  description       = "Allow Internet Proxy to reach all Internet hosts (HTTP)"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.internet_proxy.id
}

resource "aws_security_group_rule" "egress_https_to_vpc_endpoints" {
  description              = "egress_https_to_vpc_endpoints"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.internet_proxy.id
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = var.interface_vpce_sg_id
}

resource "aws_security_group_rule" "ingress_https_vpc_endpoints" {
  description              = "ingress_https_vpc_endpoints_from_emr"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.interface_vpce_sg_id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = aws_security_group.internet_proxy.id
}
