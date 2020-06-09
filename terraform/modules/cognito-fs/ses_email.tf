resource "aws_ses_domain_mail_from" "cognito_ses_mail_from" {
  domain           = var.ses_domain
  mail_from_domain = "bounce.${var.ses_domain}"
}

resource "aws_ses_email_identity" "noreply_ses_email" {
  email = "noreply@${var.ses_domain}"
}
