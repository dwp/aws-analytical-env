resource aws_vpc_peering_connection analytical-service {
  count       = length(regexall("^vpc-", var.analytical_service_vpc)) > 0 ? 1 : 0
  peer_vpc_id = var.analytical_service_vpc
  vpc_id      = var.vpc.id
  auto_accept = true
  tags        = merge(var.common_tags, { Name = "${var.name}-peering" })
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

data aws_vpc analytical_service_vpc {
  id = var.analytical_service_vpc
}
