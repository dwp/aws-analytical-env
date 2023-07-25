output "outputs" {
  value = {
    aws_availability_zones = data.aws_availability_zones.current
    aws_nat_gateways       = aws_nat_gateway.nat
    aws_subnets_private    = aws_subnet.private
    aws_subnets_public = {
      ids = aws_subnet.public.*.id
    }
    aws_vpc                     = var.vpc
    aws_route_table_private_ids = aws_route_table.private[*].id
  }
}

output "tanium_service_endpoint" {
  value = {
    id  = aws_vpc_endpoint.tanium_service.id
    dns = aws_vpc_endpoint.tanium_service.dns_entry[0].dns_name
    sg  = aws_security_group.tanium_service_endpoint.id
  }
}
