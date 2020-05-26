resource aws_iam_role role_for_lambda_pre_auth {
  name               = "Role-Lambda-Pre-Auth"
  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_lambda_pre_auth.json
  tags               = merge(var.common_tags, { Name = "${var.name_prefix}-pre-auth" })
}

data aws_iam_policy_document policy_assume_role_lambda_pre_auth {
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

resource aws_iam_role_policy role_policy_dynamodb_read_write_pre_auth {
  name   = "Policy-DynamoDB-Table-User-Read-Write"
  role   = aws_iam_role.role_for_lambda_pre_auth.id
  policy = data.aws_iam_policy_document.policy_dynamodb_read_write_pre_auth.json
}

data aws_iam_policy_document policy_dynamodb_read_write_pre_auth {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]
    resources = [aws_dynamodb_table.dynamodb_table_user.arn]
  }
}

resource aws_iam_role_policy role_policy_logs_pre_auth {
  name   = "Role-Policy-Logs-Pre-Auth"
  role   = aws_iam_role.role_for_lambda_pre_auth.id
  policy = data.aws_iam_policy_document.policy_logs_pre_auth.json
}

data aws_iam_policy_document policy_logs_pre_auth {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [aws_cloudwatch_log_group.pre_auth_lambda_logs.arn]
  }
}
