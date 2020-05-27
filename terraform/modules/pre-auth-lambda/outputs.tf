output pre_auth_lambda {
  value = aws_lambda_function.lambda_pre_auth
}

output dynamodb_table_user {
  value = {
    arn  = aws_dynamodb_table.dynamodb_table_user.arn
    name = aws_dynamodb_table.dynamodb_table_user.name
  }
}
