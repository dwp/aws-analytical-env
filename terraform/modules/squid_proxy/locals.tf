locals {
  host_ranges = jsondecode(data.aws_secretsmanager_secret_version.internet_egress.secret_binary)["host_ranges"]

  squid_config_s3_main_prefix = var.name

  fqdn = "${var.name}.${var.parent_domain_name}"
}
