data "external" "user_roles" {
  program = [
    "python3",
    "${path.module}/data_cognito_user_roles.py"

  ]
  query = {
    user_pool_id = var.user_pool_id,
    account_id   = var.target_account,
    region       = data.aws_region.current.name,

    role = format("arn:%s:%s:%s:%s:%s",
      data.aws_arn.current_session.partition,
      "iam",
      data.aws_arn.current_session.region,
      data.aws_arn.current_session.account,
      "role/${split("/", data.aws_arn.current_session.resource)[1]}"
    )
  }
}

data "aws_caller_identity" "current" {}

data "aws_arn" "current_session" {
  arn = data.aws_caller_identity.current.arn
}

data "aws_region" "current" {}
