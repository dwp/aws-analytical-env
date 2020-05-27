output "create-auth-challenge-lambda" {
  value = aws_lambda_function.lambda_create_challenge
}

output "define-auth-challenge-lambda" {
  value = aws_lambda_function.lambda_define_challenge
}

output "verify-auth-challenge-lambda" {
  value = aws_lambda_function.lambda_verify_challenge
}
