output outputs {
  value = {
    user_pool_domain = aws_cognito_user_pool_domain.main.domain
    user_pool_id     = aws_cognito_user_pool.emr.id
    user_pool_arn    = aws_cognito_user_pool.emr.arn
  }
}
