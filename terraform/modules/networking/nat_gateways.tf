resource "aws_eip" "nat" {
  count = local.zone_count
  tags  = merge(var.common_tags, { Name = "${var.name}-nat-${local.zone_names[count.index]}" })
}

resource "aws_nat_gateway" "nat" {
  count         = local.zone_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(var.common_tags, { Name = "${var.name}-nat-${local.zone_names[count.index]}" })

  depends_on = [aws_internet_gateway.igw]
}
