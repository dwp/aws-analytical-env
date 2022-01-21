resource "aws_iam_role" "policy_munge_lambda_role" {
  name               = "${var.name_prefix}-policy-munge-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
  tags               = var.common_tags
}

data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    sid     = "PolicyMungeLambdaAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy" "policy_munge_lambda_basic_policy_attach" {
  role   = aws_iam_role.policy_munge_lambda_role.name
  policy = data.aws_iam_policy_document.policy_munge_lambda_execution_policy_document.json
}

data "aws_iam_policy_document" "policy_munge_lambda_execution_policy_document" {
  statement {
    sid       = "CognitoRdsSyncMgmt"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.mgmt_rbac_lambda_role.arn]
  }

  statement {
    sid = "LambdaBasicExecution"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "policy_munge_lambda_iam_service_policy" {
  role   = aws_iam_role.policy_munge_lambda_role.id
  policy = data.aws_iam_policy_document.policy_munge_lambda_document.json
}

data "aws_iam_policy_document" "policy_munge_lambda_document" {
  statement {
    sid = "PolicyMungeLambdaIam"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:DetachRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:CreateRole",
      "iam:ListRoles",
      "iam:DeleteRole",
      "iam:GetRolePolicy",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:ListRoleTags",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateRole"
    ]
    resources = [
      "arn:aws:iam::${var.account}:policy/emrfs/*",
      "arn:aws:iam::${var.account}:role/emrfs/*"
    ]
  }

  statement {
    sid = "ReadPoliciesAndRoles"
    actions = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListPolicies"
    ]
    resources = [
      "arn:aws:iam::${var.account}:policy/*",
      "arn:aws:iam::${var.account}:role/*"
    ]
  }

  statement {
    sid    = "AllowGetCredentials"
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      var.db_client_secret_arn,
    ]
  }

  statement {
    sid       = "AllowRdsDataExecute"
    effect    = "Allow"
    actions   = ["rds-data:ExecuteStatement"]
    resources = [var.db_cluster_arn]
  }

  statement {
    sid       = "AllowKmsDescribeKey"
    effect    = "Allow"
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      values   = ["alias/*-home"]
      variable = "kms:RequestAlias"
    }
  }
}

resource "aws_cloudwatch_log_group" "policy_munge_lambda_logs" {
  name              = "${var.name_prefix}-policy-munge-lambda"
  retention_in_days = 180
  tags              = merge(var.common_tags, { "Name" : "${var.name_prefix}-policy-munge-lambda-logs" })
}


resource "aws_iam_role" "cognito_rds_sync_lambda_role" {
  name               = "${var.name_prefix}-cognito-rds-sync-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy" "cognito_rds_sync_lambda_basic_policy_attach" {
  role   = aws_iam_role.cognito_rds_sync_lambda_role.name
  policy = data.aws_iam_policy_document.cognito_rds_sync_lambda_execution_policy.json
}

data "aws_iam_policy_document" "cognito_rds_sync_lambda_execution_policy" {
  statement {
    sid       = "CognitoRdsSyncMgmt"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.mgmt_rbac_lambda_role.arn]
  }

  statement {
    sid = "LambdaBasicExecution"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cognito_rds_sync_lambda_logging_policy" {
  role   = aws_iam_role.cognito_rds_sync_lambda_role.id
  policy = data.aws_iam_policy_document.cognito_rds_sync_lambda_logging_policy_document.json
}

data "aws_iam_policy_document" "cognito_rds_sync_lambda_logging_policy_document" {
  statement {
    sid = "CognitoRdsSyncLambdaLogging"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream"
    ]
    resources = [aws_cloudwatch_log_group.cognito_rds_sync_lambda_logs.arn]
  }
}

resource "aws_iam_role_policy" "cognito_rds_sync_lambda_iam_service_policy" {
  role   = aws_iam_role.cognito_rds_sync_lambda_role.id
  policy = data.aws_iam_policy_document.cognito_rds_sync_lambda_document.json
}

data "aws_iam_policy_document" "cognito_rds_sync_lambda_document" {
  statement {
    sid    = "AllowGetCredentials"
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      var.db_client_secret_arn,
    ]
  }

  statement {
    sid       = "AllowRdsDataExecute"
    effect    = "Allow"
    actions   = ["rds-data:ExecuteStatement"]
    resources = [var.db_cluster_arn]
  }

}

resource "aws_cloudwatch_log_group" "cognito_rds_sync_lambda_logs" {
  name              = "${var.name_prefix}-cognito-rds-sync-lambda"
  retention_in_days = 180
  tags              = merge(var.common_tags, { "Name" : "${var.name_prefix}-cognito-rds-sync-lambda-logs" })
}

resource "aws_iam_role" "mgmt_rbac_lambda_role" {
  name               = "${var.name_prefix}-mgmt-cognito-rbac-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.rbac_lambdas_trust_policy.json
  tags               = var.common_tags
  provider           = aws.management
}

data "aws_iam_policy_document" "rbac_lambdas_trust_policy" {

  statement {
    sid     = "MgmtLambdaAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.cognito_rds_sync_lambda_role.arn, aws_iam_role.policy_munge_lambda_role.arn]
    }
  }
}

resource "aws_iam_role_policy" "mgmt_cognito_rds_sync_lambda_policy" {
  depends_on = [aws_iam_role.mgmt_rbac_lambda_role]
  policy     = data.aws_iam_policy_document.mgmt_rbac_lambda_document.json
  role       = aws_iam_role.mgmt_rbac_lambda_role.id
  provider   = aws.management
}

data "aws_iam_policy_document" "mgmt_rbac_lambda_document" {
  statement {
    sid = "CognitoSyncLambda"
    actions = [
      "cognito-idp:AdminListGroupsForUser",
      "cognito-idp:ListUsers",
      "cognito-idp:ListUsersInGroup",
    ]
    resources = [
      "arn:aws:cognito-idp:${var.region}:${var.mgmt_account}:userpool/${var.cognito_user_pool_id}"
    ]
  }
}
