resource "aws_cloudwatch_event_rule" "every_five_minutes" {
  name                = "every-five-minutes"
  description         = "Fires every five minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "trigger_metric_lambda_every_five_minutes" {
  rule      = aws_cloudwatch_event_rule.every_five_minutes.name
  target_id = "emr_metrics_lambda"
  arn       = aws_lambda_function.emr_metrics_lambda.arn
  input = jsonencode({
    proxy_user    = var.test_proxy_user,
    db_name       = var.metrics_database_name,
    small_dataset = var.small_test_dataset,
    large_dataset = var.large_test_dataset
  })
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_metrics_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.emr_metrics_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_five_minutes.arn
}