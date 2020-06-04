resource "aws_lambda_function" "lambda_create_challenge" {
  filename         = var.custom_auth_file_path
  function_name    = "${var.name_prefix}-create-challenge"
  role             = aws_iam_role.role_for_lambda_create_auth_challenge.arn
  handler          = "lambda.createAuthChallenge"
  runtime          = "nodejs12.x"
  timeout          = 6
  source_code_hash = filebase64sha256(var.custom_auth_file_path)
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-create-challenge", ProtectSensitiveData = "True" })
}

resource "aws_lambda_function" "lambda_define_challenge" {
  filename         = var.custom_auth_file_path
  function_name    = "${var.name_prefix}-define-challenge"
  role             = aws_iam_role.role_for_lambda_define_auth_challenge.arn
  handler          = "lambda.defineAuthChallenge"
  runtime          = "nodejs12.x"
  timeout          = 6
  source_code_hash = filebase64sha256(var.custom_auth_file_path)
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-define-challenge", ProtectSensitiveData = "True" })
}

resource "aws_lambda_function" "lambda_verify_challenge" {
  filename         = var.custom_auth_file_path
  function_name    = "${var.name_prefix}-verify-challenge"
  role             = aws_iam_role.role_for_lambda_verify_auth_challenge.arn
  handler          = "lambda.verifyAuthChallenge"
  runtime          = "nodejs12.x"
  timeout          = 6
  source_code_hash = filebase64sha256(var.custom_auth_file_path)
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-verify-challenge", ProtectSensitiveData = "True" })
}

resource "aws_lambda_function" "lambda_pre_token_generation" {
  filename         = var.custom_auth_file_path
  function_name    = "${var.name_prefix}-pre-token-generation"
  role             = aws_iam_role.role_for_lambda_pre_token_generation.arn
  handler          = "lambda.preTokenGeneration"
  runtime          = "nodejs12.x"
  timeout          = 6
  source_code_hash = filebase64sha256(var.custom_auth_file_path)
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-pre-token-generation", ProtectSensitiveData = "True" })
}

resource "aws_lambda_function" "lambda_pre_auth" {
  filename         = var.custom_auth_file_path
  function_name    = "${var.name_prefix}-pre-auth"
  role             = aws_iam_role.role_for_lambda_pre_auth.arn
  handler          = "lambda.preAuth"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256(var.custom_auth_file_path)
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-pre-auth", "ProtectSensitiveData" = "True" })
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.dynamodb_table_user.id
    }
  }
}

resource "aws_lambda_function" "lambda_post_auth" {
  filename         = var.custom_auth_file_path
  function_name    = "${var.name_prefix}-post-auth"
  role             = aws_iam_role.role_for_lambda_post_auth.arn
  handler          = "lambda.postAuth"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256(var.custom_auth_file_path)
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-post-auth", "ProtectSensitiveData" = "True" })
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.dynamodb_table_user.id
    }
  }
}
