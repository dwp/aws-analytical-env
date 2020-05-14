resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc.id
  tags   = merge(var.common_tags, { Name = var.name })
}

resource "aws_subnet" "public" {
  count                   = local.zone_count
  cidr_block              = cidrsubnet(var.vpc.cidr_block, 3, count.index + local.zone_count)
  vpc_id                  = var.vpc.id
  availability_zone_id    = data.aws_availability_zones.current.zone_ids[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(var.common_tags, { Name = "${var.name}-public-${local.zone_names[count.index]}" })
}

resource "aws_default_route_table" "public" {
  default_route_table_id = var.vpc.main_route_table_id
  tags                   = merge(var.common_tags, { Name = "${var.name}-public" })

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
