data "aws_secretsmanager_secret_version" "terraform_secrets" {
  provider  = aws.management_dns
  secret_id = "/concourse/dataworks/terraform"
}

resource "aws_service_discovery_private_dns_namespace" "azkaban_services" {
  name = "${local.environment}.azkaban.services.${jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary)["dataworks_domain_name"]}"
  vpc  = module.analytical_env_vpc.vpc.id
  tags = merge(local.common_tags, { Name = "azkaban_services" })
}

resource "aws_service_discovery_service" "azkaban_services" {
  name = "azkaban_services"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.azkaban_services.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  tags = merge(local.common_tags, { Name = "azkaban_services" })
}
