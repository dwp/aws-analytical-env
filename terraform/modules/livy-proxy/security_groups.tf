resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.name}-ecs-tasks-sg"
  description = "${var.name}-ecs-tasks-sg"
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, { Name = "${var.name}-ecs-tasks-sg" })
}

resource "aws_security_group" "lb_sg" {
  name        = "${var.name}-lb-sg"
  description = "${var.name}-lb-sg"
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, { Name = "${var.name}-lb-sg" })
}

resource aws_security_group_rule "ecs_tasks_ingress_from_alb" {
  description              = "ingress_from_alb"
  from_port                = var.container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_tasks_sg.id
  to_port                  = var.container_port
  type                     = "ingress"
  source_security_group_id = aws_security_group.lb_sg.id
}

resource aws_security_group_rule "lb_egress_to_ecs_tasks" {
  description              = "egress_to_ecs_tasks"
  from_port                = var.container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_sg.id
  to_port                  = var.container_port
  type                     = "egress"
  source_security_group_id = aws_security_group.ecs_tasks_sg.id
}

resource aws_security_group_rule ingress_https_to_vpc_endpoints {
  description              = "ingress_https_to_vpc_endpoints"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.interface_vpce_sg_id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = aws_security_group.ecs_tasks_sg.id
}

resource aws_security_group_rule egress_to_vpce {
  description              = "egress__https_to_vpc_endpoints"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_tasks_sg.id
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = var.interface_vpce_sg_id
}

resource aws_security_group_rule egress_to_s3_pl {
  description       = "egress_to_s3_pl"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks_sg.id
  to_port           = 443
  type              = "egress"
  prefix_list_ids   = [var.s3_prefix_list_id]
}

resource "aws_security_group_rule" "egress_proxy_tcp_to_livy" {
  description              = "Allow TCP egress on 8998 to Livy"
  type                     = "egress"
  from_port                = 8998
  to_port                  = 8998
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_tasks_sg.id
  source_security_group_id = var.livy_sg_id
}

resource "aws_security_group_rule" "ingress_livy_tcp_from_proxy" {
  description              = "Allow TCP ingress on 8998 from Livy proxy"
  type                     = "ingress"
  from_port                = 8998
  to_port                  = 8998
  protocol                 = "tcp"
  security_group_id        = var.livy_sg_id
  source_security_group_id = aws_security_group.ecs_tasks_sg.id
}
