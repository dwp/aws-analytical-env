resource "aws_subnet" "private" {
  count                = local.zone_count
  cidr_block           = cidrsubnet(var.vpc.cidr_block, 3, count.index)
  vpc_id               = var.vpc.id
  availability_zone_id = data.aws_availability_zones.current.zone_ids[count.index]
  tags                 = merge(var.common_tags, { Name = "${var.name}-private-${local.zone_names[count.index]}" })
}

resource "aws_route_table" "private" {
  count  = local.zone_count
  vpc_id = var.vpc.id
  tags   = merge(var.common_tags, { Name = "${var.name}-private-${local.zone_names[count.index]}" })
}

resource "aws_route_table_association" "private" {
  count          = local.zone_count
  route_table_id = aws_route_table.private[count.index].id
  subnet_id      = aws_subnet.private[count.index].id
}
