resource "aws_cloudwatch_log_group" "livy-proxy" {
  name              = "/aws/ecs/main/${var.name}"
  retention_in_days = 30
  tags              = var.common_tags
}
