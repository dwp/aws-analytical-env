// Security Groups for AWS Batch Metrics Data Job
resource "aws_security_group" "batch_job_sg" {
  name        = "${var.name_prefix}-batch-tasks-sg"
  description = "${var.name_prefix}-batch-tasks-sg"
  vpc_id      = var.vpc.aws_vpc.id
  tags        = merge(var.common_tags, { Name = "${var.name_prefix}-ecs-tasks-sg" })
}

resource "aws_security_group_rule" "egress_to_vpce" {
  description              = "egress_https_to_vpc_endpoints"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.batch_job_sg.id
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = var.interface_vpce_sg_id
}

resource "aws_security_group_rule" "egress_to_s3_pl" {
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
  from_port                = 9091
  to_port                  = 9091
  protocol                 = "tcp"
  type                     = "ingress"
  security_group_id        = var.push_host_sg
  source_security_group_id = aws_security_group.metric_lambda.id
  description              = "Allow push access from Metrics Lambda"
}

// Security group for Performance Metrics lambdas
resource "aws_security_group" "metric_lambda" {
  name        = "${var.name_prefix}-metric-lambda-sg"
  description = "Security Group for Analytical Env Metrics Lambda"
  vpc_id      = var.vpc.aws_vpc.id
  tags        = merge(var.common_tags, { Name = "${var.name_prefix}-metrics-lambda" })
}

resource "aws_security_group_rule" "metric_lambda_egress_to_vpce" {
  description              = "egress_https_to_vpc_endpoints"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.metric_lambda.id
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = var.interface_vpce_sg_id
}

resource "aws_security_group_rule" "metric_lambda_egress_to_push_host" {
  description              = "egress_https_to_push_host"
  from_port                = 9091
  protocol                 = "tcp"
  security_group_id        = aws_security_group.metric_lambda.id
  to_port                  = 9091
  type                     = "egress"
  source_security_group_id = var.push_host_sg
}

resource "aws_security_group_rule" "metric_lambda_egress_to_emr" {
  description              = "egress_to_emr_on_livy_port"
  from_port                = 8998
  protocol                 = "tcp"
  security_group_id        = aws_security_group.metric_lambda.id
  to_port                  = 8998
  type                     = "egress"
  source_security_group_id = var.emr_host_sg
}

resource "aws_security_group_rule" "ingress_https_vpc_endpoints_from_metrics_lambda" {
  description              = "ingress_https_vpc_endpoints_from_metrics_lambda"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.interface_vpce_sg_id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = aws_security_group.metric_lambda.id
}

resource "aws_security_group_rule" "ingress_livy_from_metrics_lambda" {
  from_port                = 8998
  protocol                 = "tcp"
  security_group_id        = var.emr_host_sg
  to_port                  = 8998
  type                     = "ingress"
  source_security_group_id = aws_security_group.metric_lambda.id
}

// Security groups for RBAC Lambda
resource "aws_security_group" "rbac_lambda" {
  name        = "${var.name_prefix}-rbac-test-lambda-sg"
  description = "Security Group for Analytical Env RBAC Test Lambda"
  vpc_id      = var.vpc.aws_vpc.id
  tags        = merge(var.common_tags, { Name = "${var.name_prefix}-rbac-lambda" })
}

resource "aws_security_group_rule" "rbac_lambda_egress_to_vpce" {
  description              = "egress_https_to_vpc_endpoints"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rbac_lambda.id
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = var.interface_vpce_sg_id
}

resource "aws_security_group_rule" "rbac_lambda_egress_to_emr" {
  description              = "egress_to_emr_on_livy_port"
  from_port                = 8998
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rbac_lambda.id
  to_port                  = 8998
  type                     = "egress"
  source_security_group_id = var.emr_host_sg
}

resource "aws_security_group_rule" "ingress_livy_from_rbac_lambda" {
  from_port                = 8998
  protocol                 = "tcp"
  security_group_id        = var.emr_host_sg
  to_port                  = 8998
  type                     = "ingress"
  source_security_group_id = aws_security_group.rbac_lambda.id
}


resource "aws_security_group_rule" "metrics_batch_to_internet_proxy" {
  description              = "metrics batch to Internet Proxy (for hcs services)"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3128
  to_port                  = 3128
  source_security_group_id = var.internet_proxy_sg_id
  security_group_id        = aws_security_group.batch_job_sg.id
}
resource "aws_security_group_rule" "metrics_batch_from_internet_proxy" {
  description              = "Allow proxy access from metrics batch"
  type                     = "ingress"
  from_port                = 3128
  to_port                  = 3128
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.batch_job_sg.id
  security_group_id        = var.internet_proxy_sg_id
}

resource "aws_security_group_rule" "metrics_batch_outbound_tanium_1" {
  description       = "Metrics batch outbound port 1 to Tanium"
  type              = "egress"
  from_port         = var.tanium_port_1
  to_port           = var.tanium_port_1
  protocol          = "tcp"
  prefix_list_ids   = var.tanium_prefix
  security_group_id = aws_security_group.batch_job_sg.id
}

resource "aws_security_group_rule" "metrics_batch_outbound_tanium_2" {
  description       = "Metrics batch outbound port 2 to Tanium"
  type              = "egress"
  from_port         = var.tanium_port_2
  to_port           = var.tanium_port_2
  protocol          = "tcp"
  prefix_list_ids   = var.tanium_prefix
  security_group_id = aws_security_group.batch_job_sg.id
}

resource "aws_security_group_rule" "metrics_batch_inbound_tanium_1" {
  description       = "Metrics batch inbound port 1 from Tanium"
  type              = "ingress"
  from_port         = var.tanium_port_1
  to_port           = var.tanium_port_1
  protocol          = "tcp"
  prefix_list_ids   = var.tanium_prefix
  security_group_id = aws_security_group.batch_job_sg.id
}

resource "aws_security_group_rule" "metrics_batch_inbound_tanium_2" {
  description       = "Metrics batch inbound port 2 from Tanium"
  type              = "ingress"
  from_port         = var.tanium_port_2
  to_port           = var.tanium_port_2
  protocol          = "tcp"
  prefix_list_ids   = var.tanium_prefix
  security_group_id = aws_security_group.batch_job_sg.id
}