locals {
  fqdn = format("%s.%s.%s", var.name_prefix, var.root_dns_prefix, replace(data.aws_route53_zone.main.name, "/.$/", ""))
}
