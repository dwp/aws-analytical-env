output "policy_munge_lambda" {
  value = aws_lambda_function.policy_munge_lambda
}

output "rds_sync_lambda" {
  value = aws_lambda_function.cognito_rds_sync_lambda
}
