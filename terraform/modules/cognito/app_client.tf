resource aws_cognito_user_pool_client app_client {
  for_each = toset(var.clients)

  name                                 = each.value
  user_pool_id                         = aws_cognito_user_pool.emr.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true

  callback_urls = formatlist("https://aws-analytical-env.%s/hub/oauth_callback", var.root_dns_names)

  supported_identity_providers = ["COGNITO"]

  allowed_oauth_flows = [
    "code",
    "implicit"
  ]

  allowed_oauth_scopes = [
    "email",
    "openid",
    "aws.cognito.signin.user.admin",
  ]

  explicit_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
}
