resource "aws_security_group" "batch_job_sg" {
  name        = "${var.name_prefix}-batch-tasks-sg"
  description = "${var.name_prefix}-batch-tasks-sg"
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

resource "aws_security_group_rule" "ingress_https_vpc_endpoints_from_batch" {
  description              = "ingress_https_vpc_endpoints_from_batch"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.interface_vpce_sg_id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = aws_security_group.batch_job_sg.id
}

resource "aws_security_group_rule" "ingress_to_push_gateway" {
  from_port = 9091
  to_port = 9091
  protocol = "tcp"
  type = "ingress"
  security_group_id = var.push_host_sg
  source_security_group_id = aws_security_group.sg_for_metric_lambda.id
  description = "Allow push access from Metrics Lambda"
}

// Security group for metrics lambdas that are placed in VPCs
resource "aws_security_group" "sg_for_metric_lambda" {
  name   = "${var.name_prefix}-metric-lambda-sg"
  vpc_id = var.vpc.aws_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ingress_https_vpc_endpoints_from_metrics_lambda" {
  description              = "ingress_https_vpc_endpoints_from_metrics_lambda"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.interface_vpce_sg_id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = aws_security_group.sg_for_metric_lambda.id
}

resource "aws_security_group" "sg_for_rbac_lambda" {
  name   = "${var.name_prefix}-rbac-test-lambda-sg"
  vpc_id = var.vpc.aws_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
