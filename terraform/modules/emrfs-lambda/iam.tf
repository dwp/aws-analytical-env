resource "aws_iam_role" "policy_munge_lambda_role" {
  name               = "${var.name_prefix}-policy-munge-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_munge_lambda.json
  tags               = var.common_tags
}

data "aws_iam_policy_document" "assume_role_policy_munge_lambda" {
  statement {
    sid     = "policyMungeLambdaAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "policy_munge_lambda_VPC_access_policy_attach" {
  role       = aws_iam_role.policy_munge_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "policy_munge_lambda_logging_policy" {
  role   = aws_iam_role.policy_munge_lambda_role.id
  policy = data.aws_iam_policy_document.policy_munge_lambda_logging_policy_document.json
}

data aws_iam_policy_document policy_munge_lambda_logging_policy_document {
  statement {
    sid = "policyMungeLambdaLogging"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream"
    ]
    resources = [aws_cloudwatch_log_group.policy_munge_lambda_logs.arn]
  }
}

resource "aws_iam_role_policy" "policy_munge_lambda_iam_service_policy" {
  role   = aws_iam_role.policy_munge_lambda_role.id
  policy = data.aws_iam_policy_document.policy_munge_lambda_document.json
}

data aws_iam_policy_document policy_munge_lambda_document {
  statement {
    sid = "policyMungeLambdaIam"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:DetachRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:CreateRole",
      "iam:ListRoles",
      "iam:DeleteRole",
      "iam:GetRolePolicy",
      "iam:ListPolicies",
      "iam:ListRoleTags",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateRole"
    ]
    resources = [
      "arn:aws:iam::${var.account}:policy/emrfs_*",
      "arn:aws:iam::${var.account}:role/emrfs_*"
    ]
  }
}

resource "aws_cloudwatch_log_group" "policy_munge_lambda_logs" {
  name              = "${var.name_prefix}-policy-munge-lambda"
  retention_in_days = 180
  tags              = merge(var.common_tags, { "Name" : "${var.name_prefix}-policy-munge-lambda-logs" })
}
