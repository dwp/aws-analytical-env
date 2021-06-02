resource "aws_service_discovery_private_dns_namespace" "azkaban_services" {
  name  = "${local.environment}.azkaban.services.${var.parent_domain_name}"
  vpc   = module.analytical_env_vpc.vpc.id
  tags  = merge(local.common_tags, { Name = "azkaban_services" })
}

resource "aws_service_discovery_service" "azkaban_services" {
  name  = "azkaban_services"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.azkaban_services[0].id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  tags = merge(local.common_tags, { Name = "azkaban_services" })
}
