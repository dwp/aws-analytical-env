data "http" "keystore_data" {
  url = "https://cognito-idp.${var.region}.amazonaws.com/${data.terraform_remote_state.cognito.outputs.cognito.user_pool_id}/.well-known/jwks.json"

  request_headers = {
    Accept = "application/json"
  }
}
