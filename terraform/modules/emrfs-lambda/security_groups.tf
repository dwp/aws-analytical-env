resource "aws_security_group" "policy_munge_lambda_sg" {
  name                   = "${var.name_prefix}-policy-munge-sg"
  description            = "Control access to and from lambda"
  vpc_id                 = var.vpc_id
  tags                   = merge(var.common_tags, { Name = "${var.name_prefix}-policy-munge-sg" })
  revoke_rules_on_delete = true
}

resource "aws_security_group_rule" "egress_internet_proxy" {
  description              = "Allow policy munge lambda access to proxy for IAM"
  from_port                = 3128
  protocol                 = "tcp"
  security_group_id        = aws_security_group.policy_munge_lambda_sg.id
  to_port                  = 3128
  type                     = "egress"
  source_security_group_id = var.internet_proxy_sg_id
}

resource "aws_security_group_rule" "ingress_internet_proxy" {
  description              = "Allow proxy access from policy munge lambda for IAM"
  from_port                = 3128
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.policy_munge_lambda_sg.id
  to_port                  = 3128
  type                     = "ingress"
  security_group_id        = var.internet_proxy_sg_id
}
