resource "aws_lambda_function" "lambda_create_challenge" {
  filename         = var.custom_auth_file_path
  function_name    = "${var.name_prefix}-create-challenge"
  role             = aws_iam_role.role_for_lambda_create_auth_challenge.arn
  handler          = "module.exports.createAuthChallenge"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256(var.custom_auth_file_path)
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-create-challenge" })
}

resource "aws_lambda_function" "lambda_define_challenge" {
  filename         = var.custom_auth_file_path
  function_name    = "${var.name_prefix}-define-challenge"
  role             = aws_iam_role.role_for_lambda_define_auth_challenge.arn
  handler          = "module.exports.defineAuthChallenge"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256(var.custom_auth_file_path)
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-define-challenge" })
}

resource "aws_lambda_function" "lambda_verify_challenge" {
  filename         = var.custom_auth_file_path
  function_name    = "${var.name_prefix}-verify-challenge"
  role             = aws_iam_role.role_for_lambda_verify_auth_challenge.arn
  handler          = "module.exports.verifyAuthChallenge"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256(var.custom_auth_file_path)
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-verify-challenge" })
}
