resource "aws_security_group" "policy_munge_lambda_sg" {
  name        = "${var.name_prefix}-policy-munge-sg"
  description = "Control access to lambda"
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, { Name = "${var.name_prefix}-policy-munge-sg" })
}

