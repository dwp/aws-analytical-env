resource "aws_cloudwatch_event_rule" "EMRMorningScaleUp" {
  count               = local.emr_scheduled_scaling[var.environment] == true ? 1 : 0
  name                = "EMR_Morning_Scale_Up"
  description         = "Event to trigger emr scale up"
  schedule_expression = "cron(0 6 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "EMR_Scale_up" {
  count     = local.emr_scheduled_scaling[var.environment] == true ? 1 : 0
  rule      = aws_cloudwatch_event_rule.EMRMorningScaleUp[0].name
  target_id = "SendToLambdaEMRScaleUp"
  arn       = aws_lambda_function.emr_scheduled_scaling[0].arn
}

resource "aws_cloudwatch_event_rule" "EMRMorningScaleDown" {
  count               = local.emr_scheduled_scaling[var.environment] == true ? 1 : 0
  name                = "EMR_Morning_Scale_Down"
  description         = "Event to trigger emr scale up"
  schedule_expression = "cron(0 16 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "EMR_Scale_Down" {
  count     = local.emr_scheduled_scaling[var.environment] == true ? 1 : 0
  rule      = aws_cloudwatch_event_rule.EMRMorningScaleDown[0].name
  target_id = "SendToLambdaEMRScaleDown"
  arn       = aws_lambda_function.emr_scheduled_scaling[0].arn
}

resource "aws_cloudwatch_log_group" "emr_scheduled_scaling_lambda_logs" {
  name              = "/aws/lambda/${var.name_prefix}-emr-scheduled-scaling"
  retention_in_days = 180
  tags              = merge(var.common_tags, { Name : "${var.name_prefix}-emr-scheduled-scaling" })
}
