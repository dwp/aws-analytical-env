resource "aws_lambda_function" "emr_scheduled_scaling" {
  count            = local.emr_scheduled_scaling[var.environment] == true ? 1 : 0
  filename         = data.archive_file.emr_scheduled_scaling_lambda_zip.output_path
  function_name    = "${var.name_prefix}-emr-scheduled-scaling"
  role             = aws_iam_role.emr_scheduled_scaling_role.arn
  handler          = "emr_scheduled_scaling.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.emr_scheduled_scaling_lambda_zip.output_base64sha256
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-emr-scheduled-scaling", "ProtectSensitiveData" = "False" })
  timeout          = 720

  environment {
    variables = {
      CLUSTER_ID          = aws_emr_cluster.cluster.id
      INSTANCE_GROUP_ID   = aws_emr_cluster.cluster.core_instance_group[0].id
      REGION              = var.region
      ACCOUNT             = var.account
      SCALE_UP_RULE_ARN   = aws_cloudwatch_event_rule.EMRMorningScaleUp[0].arn
      SCALE_DOWN_RULE_ARN = aws_cloudwatch_event_rule.EMRMorningScaleDown[0].arn
      UP_AUTOSCALING_POLICY = templatefile(format("%s/templates/emr/autoscaling_policy.json", path.module), {
        autoscaling_min_capacity = local.autoscaling_min_capacity_up[var.environment],
        autoscaling_max_capacity = local.autoscaling_max_capacity_up[var.environment],
        cooldown_scale_out       = 120,
        cooldown_scale_in        = 60 * 30 // Half an hour
      })
      DOWN_AUTOSCALING_POLICY = templatefile(format("%s/templates/emr/autoscaling_policy.json", path.module), {
        autoscaling_min_capacity = local.autoscaling_min_capacity_down[var.environment],
        autoscaling_max_capacity = local.autoscaling_max_capacity_down[var.environment],
        cooldown_scale_out       = 120,
        cooldown_scale_in        = 60 * 30 // Half an hour
      })
      COMMON_TAGS = join(",", [for key, val in var.common_tags : "${key}:${val}"])
    }
  }

  depends_on = [data.archive_file.emr_scheduled_scaling_lambda_zip, aws_cloudwatch_log_group.emr_scheduled_scaling_lambda_logs]
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_emr_scaling_up_lambda" {
  count         = local.emr_scheduled_scaling[var.environment] == true ? 1 : 0
  statement_id  = "AllowScalingUpExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.emr_scheduled_scaling[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.EMRMorningScaleUp[0].arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_emr_scaling_down_lambda" {
  count         = local.emr_scheduled_scaling[var.environment] == true ? 1 : 0
  statement_id  = "AllowScalingDownExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.emr_scheduled_scaling[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.EMRMorningScaleDown[0].arn
}
