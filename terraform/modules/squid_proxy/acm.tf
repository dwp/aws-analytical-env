resource "aws_acm_certificate" "internet_proxy" {
  domain_name               = local.fqdn
  certificate_authority_arn = var.cert_authority_arn

  options {
    certificate_transparency_logging_preference = "DISABLED"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.common_tags, { Name = "${var.name}-lb" })

}

