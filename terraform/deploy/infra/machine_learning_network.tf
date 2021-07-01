resource "aws_subnet" "machine_learning" {
  count = length(data.aws_availability_zones.available.names)
  cidr_block = cidrsubnet(
    module.analytical_env_vpc.vpc.cidr_block,
    6,
    count.index + 11,
  )
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = module.analytical_env_vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      "application"                              = "machine-learning"
      "Name"                                     = "machine-learning-private"
      "for-use-with-amazon-emr-managed-policies" = "true"
    },
  )
}

resource "aws_route_table" "machine_learning" {
  vpc_id = module.analytical_env_vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      "application" = "machine-learning"
      "Name"        = "machine-learning-private"
    },
  )
}

resource "aws_route_table_association" "machine_learning" {
  count          = length(data.aws_availability_zones.available.names)
  subnet_id      = element(aws_subnet.machine_learning.*.id, count.index)
  route_table_id = aws_route_table.machine_learning.id
}

resource "aws_route" "machine_learning_dks" {
  count = length(
    data.terraform_remote_state.crypto.outputs.dks_subnet.cidr_blocks,
  )
  route_table_id = aws_route_table.machine_learning.id
  destination_cidr_block = element(
    data.terraform_remote_state.crypto.outputs.dks_subnet.cidr_blocks,
    count.index,
  )
  vpc_peering_connection_id = module.networking.outputs.aws_vpc_peering_connection_accepter_crypto.id

  timeouts {
    create = "10m"
  }
}

resource "aws_route" "dks_machine_learning" {
  provider                  = aws.management-crypto
  count                     = length(aws_subnet.machine_learning.*.cidr_block)
  route_table_id            = data.terraform_remote_state.crypto.outputs.dks_route_table.id
  destination_cidr_block    = element(aws_subnet.machine_learning.*.cidr_block, count.index)
  vpc_peering_connection_id = module.networking.outputs.aws_vpc_peering_connection_accepter_crypto.id

  timeouts {
    create = "10m"
  }
}
