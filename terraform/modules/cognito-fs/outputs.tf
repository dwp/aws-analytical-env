output "outputs" {
  value = {
    user_pool_domain            = aws_cognito_user_pool_domain.main.domain
    user_pool_id                = aws_cognito_user_pool.emr.id
    user_pool_arn               = aws_cognito_user_pool.emr.arn
    adfs_identity_provider_name = aws_cognito_identity_provider.adfs_dwp.provider_name
  }
}
