resource "aws_lambda_permission" "allow_cognito_create" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_create_challenge.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = var.cognito_user_pool_arn
}

resource "aws_lambda_permission" "allow_cognito_verify" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_verify_challenge.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = var.cognito_user_pool_arn
}

resource "aws_lambda_permission" "allow_cognito_define" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_define_challenge.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = var.cognito_user_pool_arn
}

resource "aws_lambda_permission" "allow_cognito_pre_token_generation" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_pre_token_generation.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = var.cognito_user_pool_arn
}

resource "aws_lambda_permission" "allow_cognito_pre_auth" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_pre_auth.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = var.cognito_user_pool_arn
}

resource "aws_lambda_permission" "allow_cognito_post_auth" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_post_auth.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = var.cognito_user_pool_arn
}
