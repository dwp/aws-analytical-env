locals {
  zone_count = length(data.aws_availability_zones.current.zone_ids)
  zone_names = data.aws_availability_zones.current.names

  internet_egress_routes = [
    # in pair, element zero is a route table ID and element one is a cidr block,
    # in all unique combinations.
    for pair in setproduct(aws_route_table.private.*.id, var.internet_egress_proxy_subnet.cidr_blocks) : {
      rtb_id = pair[0]
      cidr   = pair[1]
    }
  ]
}
