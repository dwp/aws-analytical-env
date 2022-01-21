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
