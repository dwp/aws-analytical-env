locals {
  fqdn = format("%s.%s", var.name, var.root_dns_suffix)
}
