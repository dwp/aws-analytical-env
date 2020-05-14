resource "aws_route53_record" "cluster_cname" {
  provider = aws.management

  name    = local.fqdn
  type    = "CNAME"
  zone_id = data.aws_route53_zone.main.zone_id
  ttl     = 30
  records = [aws_emr_cluster.cluster.master_public_dns]
}
