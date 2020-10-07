resource "aws_cloudwatch_log_group" "proxy" {
  name              = "/aws/ecs/main/${var.name}"
  retention_in_days = 30
  tags              = var.common_tags
}
