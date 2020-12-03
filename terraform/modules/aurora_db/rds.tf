

resource "aws_rds_cluster" "database_cluster" {
  cluster_identifier = "${var.name_prefix}-database"
  database_name      = local.database_name
  engine             = var.engine_config.engine
  engine_version     = var.engine_config.engine_version
  engine_mode        = var.engine_config.engine_mode

  master_username = local.database_master_username
  master_password = local.database_master_password

  apply_immediately            = true
  backup_retention_period      = var.backup_config.backup_retention_period
  preferred_backup_window      = var.backup_config.preferred_backup_window
  preferred_maintenance_window = var.backup_config.preferred_maintenance_window

  db_subnet_group_name            = aws_db_subnet_group.database.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.database.name
  availability_zones              = data.aws_availability_zones.current.names
  vpc_security_group_ids          = [aws_security_group.database.id]

  lifecycle {
    ignore_changes = [master_password]
  }

  depends_on = [aws_cloudwatch_log_group.database_error, aws_cloudwatch_log_group.database_general]

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-database" })
}

resource "aws_db_subnet_group" "database" {
  name       = "${var.name_prefix}-database"
  subnet_ids = var.subnet_ids
  tags       = merge(var.common_tags, { Name = "${var.name_prefix}-database" })
}

resource "aws_rds_cluster_parameter_group" "database" {
  name        = "${var.name_prefix}-database"
  family      = var.engine_config.parameter_group_family
  description = "Parameters for the ${var.name_prefix} database"

  parameter {
    name  = "require_secure_transport"
    value = "ON"
  }

  parameter {
    name  = "general_log"
    value = "1"
  }
}
