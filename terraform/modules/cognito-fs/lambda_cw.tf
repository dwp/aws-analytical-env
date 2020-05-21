resource aws_cloudwatch_event_rule snapshot_cognito_pool {
  name        = "snapshot_cognito_pool"
  description = "Capture changes to the Cognito Pool made by an Administrator"
  depends_on = [
    "aws_lambda_function.snapshot_cognito_pool"
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
}

resource aws_cloudwatch_event_target notification {
  target_id = "CognitoSnapshotLambda"
  rule      = aws_cloudwatch_event_rule.snapshot_cognito_pool.name
  arn       = aws_lambda_function.snapshot_cognito_pool.arn
}
