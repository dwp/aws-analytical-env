output "create-auth-challenge-lambda" {
  value = aws_lambda_function.lambda_create_challenge
}

output "define-auth-challenge-lambda" {
  value = aws_lambda_function.lambda_define_challenge
}

output "verify-auth-challenge-lambda" {
  value = aws_lambda_function.lambda_verify_challenge
}

output "pre-token-generation-lambda" {
  value = aws_lambda_function.lambda_pre_token_generation
}

output "pre-auth-lambda" {
  value = aws_lambda_function.lambda_pre_auth
}

output "post-auth-lambda" {
  value = aws_lambda_function.lambda_post_auth
}

output "dynamodb_table_user" {
  value = {
    arn  = aws_dynamodb_table.dynamodb_table_user.arn
    name = aws_dynamodb_table.dynamodb_table_user.name
  }
}
