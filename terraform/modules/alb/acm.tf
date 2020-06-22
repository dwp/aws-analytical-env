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
