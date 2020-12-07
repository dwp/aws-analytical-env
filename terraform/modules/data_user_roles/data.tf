data "external" "user_roles" {
  program = [
    "python",
    "${path.module}/data_cognito_user_roles.py"

  ]
  query = {
    user_pool_id = var.user_pool_id,

    role = format("arn:%s:%s:%s:%s:%s",
      data.aws_arn.current_session.partition,
      "iam",
      data.aws_arn.current_session.region,
      data.aws_arn.current_session.account,
      "role/${split("/", data.aws_arn.current_session.resource)[1]}"
    )

    account_id = data.aws_arn.current_session.account
  }
}

data "aws_caller_identity" "current" {}

data "aws_arn" "current_session" {
  arn = data.aws_caller_identity.current.arn
}
