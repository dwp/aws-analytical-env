resource "aws_cloudwatch_metric_alarm" "munge_lambda_failure" {
  alarm_name          = "munge_lambda_failure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  alarm_description   = "This metric monitors failures of the lambda: ${aws_lambda_function.policy_munge_lambda.function_name}"
  threshold           = 1
  alarm_actions       = [var.monitoring_sns_topic_arn]
  dimensions {
    FunctionName = aws_lambda_function.policy_munge_lambda.function_name
  }

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-policy-munge-failure-alarm" })
}

resource "aws_cloudwatch_event_rule" "munge_lambda_failed" {
  name          = "munge_lambda_failed"
  description   = "checks if the munge lambda has failed"
  event_pattern = <<EOF
{
"source": [
  "aws.cloudwatch"
],
"detail-type": [
  "CloudWatch Alarm State Change"
],
"detail": {
  "alarmName": ${aws_cloudwatch_metric_alarm.munge_lambda_failure.alarm_name},
  "state": {
    "value": "ALARM"
  }
}
}
EOF
}

