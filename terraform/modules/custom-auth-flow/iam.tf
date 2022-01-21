/* Roles */

resource "aws_iam_role" "role_for_lambda_create_auth_challenge" {
  name               = "Role-Lambda-Create-Auth_Challenge"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
  tags               = merge(var.common_tags, { Name : "${var.name_prefix}-auth-challenge" })
}
resource "aws_iam_role" "role_for_lambda_define_auth_challenge" {
  name               = "Role-Lambda-Define-Auth_Challenge"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
  tags               = merge(var.common_tags, { Name : "${var.name_prefix}-define-auth" })
}
resource "aws_iam_role" "role_for_lambda_verify_auth_challenge" {
  name               = "Role-Lambda-Verify-Auth_Challenge"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
  tags               = merge(var.common_tags, { Name : "${var.name_prefix}-verify-auth" })
}

resource "aws_iam_role" "role_for_lambda_pre_token_generation" {
  name               = "Role-Lambda-Pre-Token-Generation"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
  tags               = merge(var.common_tags, { Name : "${var.name_prefix}-pre-token" })
}

resource "aws_iam_role" "role_for_lambda_pre_auth" {
  name               = "Role-Lambda-Pre-Auth"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
  tags               = merge(var.common_tags, { Name = "${var.name_prefix}-pre-auth" })
}

resource "aws_iam_role" "role_for_lambda_post_auth" {
  name               = "Role-Lambda-Post-Auth"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
  tags               = merge(var.common_tags, { Name = "${var.name_prefix}-post-auth" })
}

data "aws_iam_policy_document" "assume_role_lambda" {
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

/* Basic execution role attachements */

resource "aws_iam_role_policy_attachment" "cognito_create_challenge_basic_execution" {
  role       = aws_iam_role.role_for_lambda_create_auth_challenge.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "cognito_verify_challenge_basic_execution" {
  role       = aws_iam_role.role_for_lambda_verify_auth_challenge.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "cognito_define_challenge_trigger_basic_execution" {
  role       = aws_iam_role.role_for_lambda_define_auth_challenge.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "cognito_pre_token_generation_basic_execution" {
  role       = aws_iam_role.role_for_lambda_pre_token_generation.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "cognito_pre_auth_basic_execution" {
  role       = aws_iam_role.role_for_lambda_pre_auth.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "cognito_post_auth_basic_execution" {
  role       = aws_iam_role.role_for_lambda_post_auth.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

/* Create Auth Challenge policy */

resource "aws_iam_role_policy" "cognito_create_auth_policy" {
  policy = data.aws_iam_policy_document.cognito_create_auth_policy_document.json
  role   = aws_iam_role.role_for_lambda_create_auth_challenge.name
}

// Work around for AWS SMS / SNS - SEE - https://stackoverflow.com/questions/38871201/authorization-when-sending-a-text-message-using-amazonsnsclient
data "aws_iam_policy_document" "cognito_create_auth_policy_document" {
  statement {
    sid    = "AllowLambdaToSendSNSToAllResources"
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "DenyLambdaSNSPublishOnAWSResoruces"
    effect = "Deny"
    actions = [
      "sns:Publish"
    ]
    resources = ["arn:aws:sns:*:*:*"]
  }
}

/* Define Auth Challenge policy */

resource "aws_iam_role_policy" "cognito_define_auth_policy" {
  policy = data.aws_iam_policy_document.cognito_define_auth_policy.json
  role   = aws_iam_role.role_for_lambda_define_auth_challenge.name
}

data "aws_iam_policy_document" "cognito_define_auth_policy" {
  statement {
    sid    = "AllowCognitoGetUser"
    effect = "Allow"
    actions = [
      "cognito-idp:AdminGetUser",
    ]
    resources = [
      var.cognito_user_pool_arn
    ]
  }
}

/* Pre Auth Policy */

resource "aws_iam_role_policy" "cognito_pre_auth_policy" {
  policy = data.aws_iam_policy_document.cognito_pre_auth_policy.json
  role   = aws_iam_role.role_for_lambda_pre_auth.name
}

data "aws_iam_policy_document" "cognito_pre_auth_policy" {
  statement {
    sid    = "AllowRWUserDynamoDBTable"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]
    resources = [aws_dynamodb_table.dynamodb_table_user.arn]
  }

  statement {
    sid    = "AllowCognitoAdminResetPassword"
    effect = "Allow"
    actions = [
      "cognito-idp:AdminResetUserPassword"
    ]
    resources = [var.cognito_user_pool_arn]
  }
}

/* Post Auth Policy */

resource "aws_iam_role_policy" "cognito_pre_post_auth_policy" {
  policy = data.aws_iam_policy_document.cognito_post_auth_policy.json
  role   = aws_iam_role.role_for_lambda_post_auth.name
}

data "aws_iam_policy_document" "cognito_post_auth_policy" {
  statement {
    sid    = "AllowRWUserDynamoDBTable"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]
    resources = [aws_dynamodb_table.dynamodb_table_user.arn]
  }
}
