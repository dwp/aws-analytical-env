locals {
  host_ranges = jsondecode(data.aws_secretsmanager_secret_version.internet_egress.secret_binary)["host_ranges"]

  squid_config_s3_main_prefix = var.name

  env_prefix = {
    management-dev = "mgt-dev."
    management     = "mgt."
  }

  fqdn = "${var.name}.${var.parent_domain_name}"
}
