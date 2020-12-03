resource "aws_cloudwatch_log_group" "database_error" {
  name              = "/aws/rds/cluster/${var.name_prefix}-database/error"
  retention_in_days = 30
  tags              = var.common_tags
}

resource "aws_cloudwatch_log_group" "database_general" {
  name              = "/aws/rds/cluster/${var.name_prefix}-database/general"
  retention_in_days = 30
  tags              = var.common_tags
}

