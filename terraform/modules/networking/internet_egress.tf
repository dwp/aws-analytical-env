resource aws_ec2_transit_gateway_vpc_attachment internet_egress {
  subnet_ids         = tolist(aws_subnet.private.*.id)
  transit_gateway_id = var.internet_transit_gateway.id
  vpc_id             = var.vpc.id

  tags = merge(var.common_tags, { Name = var.name })
}

resource aws_ec2_transit_gateway_vpc_attachment_accepter internet_egress {
  provider = aws.management-internet-egress

  transit_gateway_attachment_id                   = aws_ec2_transit_gateway_vpc_attachment.internet_egress.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(var.common_tags, { Name = var.name })
}

resource aws_ec2_transit_gateway_route_table internet_egress {
  provider = aws.management-internet-egress

  transit_gateway_id = var.internet_transit_gateway.id

  tags = merge(var.common_tags, { Name = var.name })

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.internet_egress]
}

resource aws_ec2_transit_gateway_route_table_association internet_egress {
  provider = aws.management-internet-egress

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.internet_egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.internet_egress.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.internet_egress]
}

resource aws_ec2_transit_gateway_route management_internet_egress_to_internet_egress_a {
  provider = aws.management-internet-egress

  destination_cidr_block         = var.proxy_subnet.cidr_blocks[0]
  transit_gateway_attachment_id  = var.tgw_attachment_internet_egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.internet_egress.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.internet_egress]
}

resource aws_ec2_transit_gateway_route management_internet_egress_to_internet_egress_b {
  provider = aws.management-internet-egress

  destination_cidr_block         = var.proxy_subnet.cidr_blocks[1]
  transit_gateway_attachment_id  = var.tgw_attachment_internet_egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.internet_egress.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.internet_egress]
}

resource aws_ec2_transit_gateway_route management_internet_egress_to_internet_egress_c {
  provider = aws.management-internet-egress

  destination_cidr_block         = var.proxy_subnet.cidr_blocks[2]
  transit_gateway_attachment_id  = var.tgw_attachment_internet_egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.internet_egress.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.internet_egress]
}

resource aws_route analytical_env_to_internet_egress {
  count = length(aws_route_table.private[*].id) * length(var.internet_egress_proxy_subnet.cidr_blocks)

  destination_cidr_block = local.internet_egress_routes[count.index].cidr
  route_table_id         = local.internet_egress_routes[count.index].rtb_id
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.internet_egress.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.internet_egress]
}

resource aws_route internet_egress_to_analytical_env {
  provider               = aws.management-internet-egress
  count                  = length(var.proxy_route_table.ids)
  route_table_id         = var.proxy_route_table.ids[count.index]
  destination_cidr_block = var.vpc.cidr_block
  transit_gateway_id     = var.internet_transit_gateway.id
}

resource aws_ec2_transit_gateway_route management_internet_egress_to_internet_egress {
  provider = aws.management-internet-egress

  destination_cidr_block         = var.vpc.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.internet_egress.id
  transit_gateway_route_table_id = var.tgw_rtb_internet_egress.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.internet_egress]
}
