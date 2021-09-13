resource "aws_cloudwatch_metric_alarm" "analytical_env_emr_launcher_lambda_failure" {
  count                     = var.alarm_on_failure
  alarm_name                = "${title(var.name_prefix)} Launcher Lambda - Failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring when ${var.name_prefix} launcher lambda fails"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  alarm_actions             = [var.alarm_sns_arn]
  dimensions = {
    FunctionName = aws_lambda_function.aws_analytical_env_emr_launcher.function_name
    Resource     = aws_lambda_function.aws_analytical_env_emr_launcher.function_name
  }
  tags = {
    Name              = "${title(var.name_prefix)} Launcher Lambda - Failed",
    notification_type = "Error",
    severity          = "Critical"
  }
}
