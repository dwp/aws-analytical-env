resource "aws_vpc_peering_connection" "crypto" {
  peer_owner_id = var.crypto_vpc_owner_id
  peer_vpc_id   = var.crypto_vpc.id
  vpc_id        = var.vpc.id
  tags          = var.common_tags
}

resource "aws_vpc_peering_connection_accepter" "crypto" {
  provider = aws.management-crypto

  vpc_peering_connection_id = aws_vpc_peering_connection.crypto.id
  auto_accept               = true
  tags                      = var.common_tags

  depends_on = [aws_vpc_peering_connection.crypto]
}

resource "aws_vpc_peering_connection_options" "crypto_accepter" {
  provider = aws.management-crypto

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.crypto.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  depends_on = [aws_vpc_peering_connection_accepter.crypto]
}

resource "aws_vpc_peering_connection_options" "crypto_requester" {
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.crypto.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  depends_on = [aws_vpc_peering_connection_accepter.crypto]
}

resource "aws_route" "private_a_to_dks" {
  for_each = toset(var.dks_subnet.cidr_blocks)

  route_table_id            = aws_route_table.private[0].id
  destination_cidr_block    = each.value
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.crypto.id
}

resource "aws_route" "private_b_to_dks" {
  for_each = toset(var.dks_subnet.cidr_blocks)

  route_table_id            = aws_route_table.private[1].id
  destination_cidr_block    = each.value
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.crypto.id
}

resource "aws_route" "private_c_to_dks" {
  for_each = toset(var.dks_subnet.cidr_blocks)

  route_table_id            = aws_route_table.private[2].id
  destination_cidr_block    = each.value
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.crypto.id
}

resource "aws_route" "dks_to_private" {
  provider = aws.management-crypto
  for_each = toset(aws_subnet.private[*].cidr_block)

  route_table_id            = var.dks_route_table.id
  destination_cidr_block    = each.value
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.crypto.id
}
