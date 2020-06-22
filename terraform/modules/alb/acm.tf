resource "aws_acm_certificate" "analytical-alb-cert" {
  domain_name               = local.fqdn
  certificate_authority_arn = var.cert_authority_arn

  options {
    certificate_transparency_logging_preference = "DISABLED"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-lb" })
}

resource "aws_acm_certificate" "analytical-alb-cert-pub" {
  domain_name       = local.fqdn
  validation_method = "DNS"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-lb" })
}
