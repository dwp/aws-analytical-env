resource "aws_cloudwatch_event_rule" "snapshot_cognito_pool" {
  name        = "snapshot_cognito_pool"
  description = "Capture changes to the Cognito Pool made by an Administrator"
  depends_on = [
    aws_lambda_function.snapshot_cognito_pool
  ]
  event_pattern = <<PATTERN
    {
       "source": [
           "aws.cognito-idp"
       ],
       "detail-type": [
           "AWS API Call via CloudTrail"
       ],
       "detail": {
           "eventSource": [
               "cognito-idp.amazonaws.com"
           ],
           "eventName": [
               "AdminAddUserToGroup",
               "AdminCreateUser",
               "AdminDeleteUser",
               "AdminDisableUser",
               "AdminEnableUser",
               "AdminRemoveUserFromGroup",
               "AdminSetUserMFAPreference",
               "AdminSetUserPassword",
               "AdminSetUserSettings",
               "CreateGroup",
               "DeleteGroup"
           ]
        }
    }
    PATTERN
  tags          = merge(var.common_tags, { Name : "${var.name_prefix}-cognito-pool-rule" })
}

resource "aws_cloudwatch_event_target" "notification" {
  target_id = "CognitoSnapshotLambda"
  rule      = aws_cloudwatch_event_rule.snapshot_cognito_pool.name
  arn       = aws_lambda_function.snapshot_cognito_pool.arn
}

resource "aws_cloudwatch_log_group" "snapshot_cognito_pool" {
  name              = "/aws/lambda/snapshot_cognito_pool"
  retention_in_days = 180
  tags              = merge(var.common_tags, { Name : "${var.name_prefix}-cognito-pool-logs" })
}
