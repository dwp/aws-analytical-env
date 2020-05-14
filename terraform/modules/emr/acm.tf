resource "aws_acm_certificate" "emr" {
  domain_name               = local.fqdn
  certificate_authority_arn = var.cert_authority_arn
}
