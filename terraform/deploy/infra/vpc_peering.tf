resource "aws_vpc_peering_connection" "internal_compute" {
  peer_owner_id = local.account[local.environment]
  peer_vpc_id   = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.id
  vpc_id        = module.networking.outputs.aws_vpc.id

  tags = merge(
    local.common_tags,
    { Name = "analytical_env <--> internal_compute (${local.environment})" }
  )
}

resource "aws_vpc_peering_connection_accepter" "internal_compute" {
  provider                  = aws.internal_compute
  vpc_peering_connection_id = aws_vpc_peering_connection.internal_compute.id
  auto_accept               = true

  tags = merge(
    local.common_tags,
    { Name = "analytical_env <--> internal_compute (${local.environment})" }
  )
}

resource "aws_route" "analytical_env_to_internal_compute" {
  count                     = length(data.aws_availability_zones.available.names)
  destination_cidr_block    = data.terraform_remote_state.internal_compute.outputs.vpc.vpc.vpc.cidr_block
  route_table_id            = module.networking.outputs.aws_route_table_private_ids[count.index]
  vpc_peering_connection_id = aws_vpc_peering_connection.internal_compute.id
}

resource "aws_route" "internal_compute_to_analytical_env" {
  count                     = length(data.aws_availability_zones.available.names)
  provider                  = aws.internal_compute
  destination_cidr_block    = module.networking.outputs.aws_subnets_private[count.index].cidr_block
  route_table_id            = data.terraform_remote_state.internal_compute.outputs.route_table_ids.pdm
  vpc_peering_connection_id = aws_vpc_peering_connection.internal_compute.id
}

resource "aws_route" "internal_compute_to_analytical_env_new_pdm_subnets" {
  count                     = length(data.aws_availability_zones.available.names)
  provider                  = aws.internal_compute
  destination_cidr_block    = module.networking.outputs.aws_subnets_private[count.index].cidr_block
  route_table_id            = data.terraform_remote_state.internal_compute.outputs.route_table_ids.pdm_new
  vpc_peering_connection_id = aws_vpc_peering_connection.internal_compute.id
}
