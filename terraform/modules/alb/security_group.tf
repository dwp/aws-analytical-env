resource "aws_security_group" "lb_sg" {
  name                   = "${var.name_prefix}-lb-sg"
  description            = "Control access to LB"
  vpc_id                 = var.vpc_id
  tags                   = merge(var.common_tags, { Name = "${var.name_prefix}-lb-sg" })
  revoke_rules_on_delete = true
}

resource "aws_security_group_rule" "ingress_to_alb" {
  description       = "ingress_to_alb"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lb_sg.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = var.whitelist_cidr_blocks
}
