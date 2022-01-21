resource "aws_iam_role" "role_for_lambda_check_user_expiry" {
  name               = "Role-Lambda-Check-User-Expiry"
  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_lambda_check_user_expiry.json
  tags               = merge(var.common_tags, { Name = "${var.name_prefix}-check-user-expiry" })
}

data "aws_iam_policy_document" "policy_assume_role_lambda_check_user_expiry" {
  statement {
    sid = "AllowLambdaToAssumeRole"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "role_policy_dynamodb_read_check_user_expiry" {
  name   = "Policy-DynamoDB-Table-User-Read-Check-User-Expiry"
  role   = aws_iam_role.role_for_lambda_check_user_expiry.id
  policy = data.aws_iam_policy_document.policy_dynamodb_read_check_user_expiry.json
}

data "aws_iam_policy_document" "policy_dynamodb_read_check_user_expiry" {
  statement {
    sid = "CheckUserExpiryDynamoDB"
    actions = [
      "dynamodb:Scan"
    ]
    resources = [var.dynamodb_table_user_arn]
  }
}

resource "aws_iam_role_policy" "role_policy_logs_check_user_expiry" {
  name   = "Role-Policy-Logs-Check-User-Expiry"
  role   = aws_iam_role.role_for_lambda_check_user_expiry.id
  policy = data.aws_iam_policy_document.policy_logs_check_user_expiry.json
}

data "aws_iam_policy_document" "policy_logs_check_user_expiry" {
  statement {
    sid = "AllowLambdaCreateLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.check_user_expiry_lambda_logs_updated.arn}:*"]
  }
}

resource "aws_iam_role_policy" "role_policy_cognito_check_user_expiry" {
  name   = "Role-Policy-Cognito-Check-User-Expiry"
  role   = aws_iam_role.role_for_lambda_check_user_expiry.id
  policy = data.aws_iam_policy_document.policy_cognito_check_user_expiry.json
}

data "aws_iam_policy_document" "policy_cognito_check_user_expiry" {
  statement {
    sid = "AllowLambdaCheckUserExpiryCognito"
    actions = [
      "cognito-idp:AdminGetUser"
    ]
    resources = [var.cognito_user_pool_arn]
  }
}

resource "aws_iam_role_policy" "role_policy_s3_check_user_expiry" {
  name   = "Role-Policy-S3-Check-User-Expiry"
  role   = aws_iam_role.role_for_lambda_check_user_expiry.id
  policy = data.aws_iam_policy_document.policy_s3_check_user_expiry.json
}

data "aws_iam_policy_document" "policy_s3_check_user_expiry" {
  statement {
    sid = "AllowLambdaGetS3Object"
    actions = [
      "s3:GetObject"
    ]
    resources = ["arn:aws:s3:::${var.template_bucket}/*"]
  }
  statement {
    sid = "AllowLambdaListBucket"
    actions = [
      "s3:ListBucket"
    ]
    resources = ["arn:aws:s3:::${var.template_bucket}"]
  }
}

resource "aws_iam_role_policy" "role_policy_ses_send_reminder_email" {
  name   = "Role-Policy-SES-Check-User-Expiry"
  role   = aws_iam_role.role_for_lambda_check_user_expiry.id
  policy = data.aws_iam_policy_document.policy_ses_send_reminder_email.json
}

data "aws_iam_policy_document" "policy_ses_send_reminder_email" {
  statement {
    sid = "AllowLambdaSendEmail"
    actions = [
      "SES:SendEmail",
      "SES:SendRawEmail"
    ]
    resources = ["arn:aws:ses:${var.region_domain}:${data.aws_caller_identity.current.account_id}:identity/*"]
  }
}
