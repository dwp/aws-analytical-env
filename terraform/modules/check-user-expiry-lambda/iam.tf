resource aws_iam_role role_for_lambda_check_user_expiry {
  name               = "Role-Lambda-Check-User-Expiry"
  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_lambda_check_user_expiry.json
  tags               = merge(var.common_tags, { Name = "${var.name_prefix}-check-user-expiry" })
}

data aws_iam_policy_document policy_assume_role_lambda_check_user_expiry {
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

resource aws_iam_role_policy role_policy_dynamodb_read_check_user_expiry {
  name   = "Policy-DynamoDB-Table-User-Read-Check-User-Expiry"
  role   = aws_iam_role.role_for_lambda_check_user_expiry.id
  policy = data.aws_iam_policy_document.policy_dynamodb_read_check_user_expiry.json
}

data aws_iam_policy_document policy_dynamodb_read_check_user_expiry {
  statement {
    actions = [
      "dynamodb:Scan"
    ]
    resources = [var.dynamodb_table_user_arn]
  }
}

resource aws_iam_role_policy role_policy_logs_check_user_expiry {
  name   = "Role-Policy-Logs-Check-User-Expiry"
  role   = aws_iam_role.role_for_lambda_check_user_expiry.id
  policy = data.aws_iam_policy_document.policy_logs_check_user_expiry.json
}

data aws_iam_policy_document policy_logs_check_user_expiry {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [aws_cloudwatch_log_group.check_user_expiry_lambda_logs.arn]
  }
}

resource aws_iam_role_policy role_policy_cognito_check_user_expiry {
  name   = "Role-Policy-Cognito-Check-User-Expiry"
  role   = aws_iam_role.role_for_lambda_check_user_expiry.id
  policy = data.aws_iam_policy_document.policy_cognito_check_user_expiry.json
}

data aws_iam_policy_document policy_cognito_check_user_expiry {
  statement {
    actions = [
      "cognito-idp:AdminGetUser"
    ]
    resources = [var.cognito_user_pool_id]
  }
}

resource aws_iam_role_policy role_policy_s3_check_user_expiry {
  name   = "Role-Policy-S3-Check-User-Expiry"
  role   = aws_iam_role.role_for_lambda_check_user_expiry.id
  policy = data.aws_iam_policy_document.policy_s3_check_user_expiry.json
}

data aws_iam_policy_document policy_s3_check_user_expiry {
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.check_user_expiry_email.arn}/*"]
  }
}
