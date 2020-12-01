resource "aws_security_group" "policy_munge_lambda_sg" {
  name        = "${var.name_prefix}-policy-munge-sg"
  description = "Control access to lambda"
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, { Name = "${var.name_prefix}-policy-munge-sg" })
}

resource "aws_security_group" "cognito_user_policy_db_sg" {
  name        = "${var.name_prefix}-cognito-user-policy-db-sg"
  description = "Control access to db"
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, { Name = "${var.name_prefix}-cognito-user-policy-db-sg" })
}

resource "aws_security_group_rule" "cognito_user_policy_db_egress_to_front_end" {
  from_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.cognito_user_policy_db_sg.id
  to_port = 443
  type = "egress"
}

resource "aws_security_group_rule" "cognito_user_policy_db_ingress_from_front_end" {
  from_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.cognito_user_policy_db_sg.id
  to_port = 443
  type = "ingress"
}


