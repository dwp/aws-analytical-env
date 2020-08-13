resource "aws_security_group" "batch_job_sg" {
  name        = "${var.name_prefix}-ecs-tasks-sg"
  description = "${var.name_prefix}-ecs-tasks-sg"
  vpc_id      = var.vpc.aws_vpc.id
  tags        = merge(var.common_tags, { Name = "${var.name_prefix}-ecs-tasks-sg" })
}

resource aws_security_group_rule egress_to_vpce {
  description              = "egress__https_to_vpc_endpoints"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.batch_job_sg.id
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = var.interface_vpce_sg_id
}

resource aws_security_group_rule egress_to_s3_pl {
  description       = "egress_to_s3_pl"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.batch_job_sg.id
  to_port           = 443
  type              = "egress"
  prefix_list_ids   = [var.s3_prefixlist_id]
}
