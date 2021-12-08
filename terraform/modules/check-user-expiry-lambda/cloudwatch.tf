resource "aws_cloudwatch_log_group" "check_user_expiry_lambda_logs" {
  name              = "${var.name_prefix}-check-user-expiry-lambda-logs"
  retention_in_days = 180
  tags              = merge(var.common_tags, { Name : "${var.name_prefix}-expiry-logs" })
}

resource "aws_cloudwatch_log_group" "check_user_expiry_lambda_logs_updated" {
  name              = "/aws/lambda/${var.name_prefix}-check-user-expiry"
  retention_in_days = 180
  tags              = merge(var.common_tags, { Name : "${var.name_prefix}-expiry-logs" })
}

resource "aws_cloudwatch_event_rule" "rule_for_check_user_expiry_lambda" {
  name                = "Rule-For-Check-User-Expiry-Lambda"
  description         = "Trigger the lambda check user expiry once a day"
  schedule_expression = "cron(0 10 * * ? *)"
  tags                = merge(var.common_tags, { Name = "${var.name_prefix}-check-user-expiry" })
}

resource "aws_cloudwatch_event_target" "target_for_rule_check_user_expiry" {
  rule      = aws_cloudwatch_event_rule.rule_for_check_user_expiry_lambda.name
  target_id = "target-run-lambda-check-user-expiry-once-day"
  arn       = aws_lambda_function.lambda_check_user_expiry.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_user_expiry" {
  statement_id  = "Allow-Execution-Check-User-Expiry-From-CloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_check_user_expiry.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule_for_check_user_expiry_lambda.arn
}
