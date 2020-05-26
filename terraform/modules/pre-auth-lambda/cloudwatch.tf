resource "aws_cloudwatch_log_group" "pre_auth_lambda_logs" {
  name              = "${var.name_prefix}-pre-auth-lambda-logs"
  retention_in_days = 180
}
