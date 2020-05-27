data aws_iam_policy_document snapshot_cognito_pool_lambda {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data aws_iam_policy_document lambda_s3 {
  statement {
    actions = [
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket}",
      "arn:aws:s3:::${var.s3_bucket}/*",
    ]
  }
}

data aws_iam_policy_document lambda_logging {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_cloudwatch_log_group.snapshot_cognito_pool.arn,
    ]
  }
}

resource aws_iam_role lambda_execution_role {
  name               = "snapshot-cognito-pool-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.snapshot_cognito_pool_lambda.json
}

resource aws_iam_role_policy lambda_log {
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.lambda_logging.json
}

resource aws_iam_role_policy lambda_s3 {
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.lambda_s3.json
}

resource aws_iam_role_policy_attachment cognito_ro_attach {
  role       = aws_iam_role.lambda_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoReadOnly"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.snapshot_cognito_pool.function_name
  principle     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.snapshot_cognito_pool.arn
}