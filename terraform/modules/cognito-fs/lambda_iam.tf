data "aws_iam_policy_document" "snapshot_cognito_pool_lambda" {
  statement {
    sid = "CognitoPoolLambdaAssumeRole"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_s3" {
  statement {
    sid = "AllowLambdaS3PutSnapshotBucket"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_log_bucket}/CognitoSnapshots/*",
    ]
  }
  statement {
    sid = "AllowLambdaKMSActionsAuditKey"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = [
      aws_kms_key.cognito_audit_kms.arn,
    ]
  }
}

data "aws_iam_policy_document" "lambda_s3_list" {
  statement {
    sid = "AllowLambdas3ListLogBucket"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_log_bucket}",
    ]
  }
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    sid = "AllowLambdaLoggingToSnapshotLogGroup"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [
      aws_cloudwatch_log_group.snapshot_cognito_pool.arn,
    ]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "snapshot-cognito-pool-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.snapshot_cognito_pool_lambda.json
  tags               = merge(var.common_tags, { Name : "${var.name_prefix}-cognito-execution" })
}

resource "aws_iam_role_policy" "lambda_log" {
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy" "lambda_s3" {
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.lambda_s3.json
}

resource "aws_iam_role_policy" "lambda_s3_list" {
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.lambda_s3_list.json
}

resource "aws_iam_role_policy_attachment" "cognito_ro_attach" {
  role       = aws_iam_role.lambda_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoReadOnly"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.snapshot_cognito_pool.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.snapshot_cognito_pool.arn
}

data "aws_iam_policy_document" "cognito_logs_kms_key" {

  statement {
    sid    = "EnableIAMPermissionsBreakglass"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_user.breakglass.arn]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid       = "EnableIAMPermissionsCI"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      identifiers = [data.aws_iam_role.ci.arn]
      type        = "AWS"
    }
  }

  statement {
    sid    = "DenyCIEncryptDecrypt"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.ci.arn]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ImportKeyMaterial",
      "kms:ReEncryptFrom",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "EnableIAMPermissionsAdministrator"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.administrator.arn]
    }

    actions = [
      "kms:Describe*",
      "kms:List*",
      "kms:Get*",
      "kms:*" //temp for local testing
    ]

    resources = ["*"]
  }

  statement {
    sid    = "EnableAWSConfigManagerScanForSecurityHub"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.aws_config.arn]
    }

    actions = [
      "kms:Describe*",
      "kms:Get*",
      "kms:List*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "EnableIAMPermissionsCognitoAuditLambdaRole"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.lambda_execution_role.arn]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]

  }
}
