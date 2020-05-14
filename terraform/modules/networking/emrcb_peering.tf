resource aws_vpc_peering_connection cluster-broker {
  count       = length(regexall("^vpc-", var.clusterbroker_vpc)) > 0 ? 1 : 0
  peer_vpc_id = var.clusterbroker_vpc
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

data aws_vpc clusterbroker {
  id = var.clusterbroker_vpc
}
