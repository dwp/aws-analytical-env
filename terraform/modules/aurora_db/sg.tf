resource "aws_security_group" "database" {
  name        = "${var.name_prefix}-database"
  description = "Rules necesary for allowing access to the database"
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, { Name = "${var.name_prefix}-database" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "rotate_password" {
  name        = "${var.name_prefix}-rotate-password"
  description = "Rules necesary for rotating ${var.name_prefix} database passwords"
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, { Name = "${var.name_prefix}-rotate-password" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_rotate_password_lambda_ingress_database" {
  description              = "Allows rotate password lambda to access ${var.name_prefix} database"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = aws_rds_cluster.database_cluster.port
  to_port                  = aws_rds_cluster.database_cluster.port
  security_group_id        = aws_security_group.database.id
  source_security_group_id = aws_security_group.rotate_password.id
}

resource "aws_security_group_rule" "allow_rotate_password_lambda_egress_database" {
  description              = "Allows rotate password lambda to access ${var.name_prefix} database"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = aws_rds_cluster.database_cluster.port
  to_port                  = aws_rds_cluster.database_cluster.port
  security_group_id        = aws_security_group.rotate_password.id
  source_security_group_id = aws_security_group.database.id
}
