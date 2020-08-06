locals {
  fqdn = format("%s.%s", var.name_prefix, var.root_dns_suffix)
}
