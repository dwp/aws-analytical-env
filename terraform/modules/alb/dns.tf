resource "aws_route53_record" "record" {
  provider = aws.management-dns

  name    = local.fqdn
  type    = "A"
  zone_id = data.aws_route53_zone.main.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
  }
}

resource "aws_route53_record" "record_acm_verify" {
  provider = aws.management-dns

  name    = aws_acm_certificate.analytical-alb-cert-pub.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.analytical-alb-cert-pub.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.main.zone_id

  records = [aws_acm_certificate.analytical-alb-cert-pub.domain_validation_options.0.resource_record_value]
}
