provider "aws" {
  alias  = "ireland-mgmt"
  region = "eu-west-1"

  assume_role {
    role_arn = var.role_arn.management
  }
}

resource "aws_ses_domain_mail_from" "cognito_ses_mail_from" {
  provider         = aws.ireland-mgmt
  domain           = var.ses_domain
  mail_from_domain = "bounce.${var.ses_domain}"
}

resource "aws_ses_email_identity" "noreply_ses_email" {
  provider = aws.ireland-mgmt
  email    = "noreply@${var.ses_domain}"
}
