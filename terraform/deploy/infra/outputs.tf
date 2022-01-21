output "vpc" {
  value = module.networking.outputs
}

output "alb" {
  value = {
    name = module.alb.lb.name
  }
}

output "alb_sg" {
  value = {
    id = module.alb.lb_sg.id
  }
}

output "alb_fqdn" {
  value = module.alb.fqdn
}

output "root_dns_name" {
  description = "The Root DNS Zone Name record we created"
  value       = local.root_dns_name[local.environment]
}

output "parent_domain_name" {
  description = "The Parent Domain Name record we created"
  value       = local.parent_domain_name[local.environment]
}

output "alb_listner" {
  value = {
    arn = module.alb.alb_listener.arn
  }
}

output "vpc_main" {
  value = module.analytical_env_vpc
}

output "interface_vpce_sg_id" {
  value = module.analytical_env_vpc.interface_vpce_sg_id
}

output "s3_prefix_list_id" {
  value = module.analytical_env_vpc.prefix_list_ids.s3
}

output "dynamodb_prefix_list_id" {
  value = module.analytical_env_vpc.prefix_list_ids.dynamodb
}

output "internet_proxy_dns_name" {
  value = module.analytical_env_vpc.custom_vpce_dns_names["proxy_vpc_endpoint"][0]
}

output "github_proxy_dns_name" {
  value = module.analytical_env_vpc.custom_vpce_dns_names["github_proxy_vpc_endpoint"][0]
}

output "internet_proxy_sg" {
  value = module.analytical_env_vpc.custom_vpce_sg_id
}

output "no_proxy_list" {
  value = module.analytical_env_vpc.no_proxy_list
}

output "private_dns" {
  value = {
    azkaban_service_discovery_dns = aws_service_discovery_private_dns_namespace.azkaban_services
    azkaban_service_discovery     = aws_service_discovery_service.azkaban_services
  }
}

output "vpce_security_groups" {
  value = {
    azkaban_pushgateway_vpce_security_group = {
      id = aws_security_group.azkaban_pushgateway_vpce_security_group.id
    }
  }
}
