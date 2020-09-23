resource "aws_vpc_endpoint" "internet_proxy" {
  vpc_id              = var.vpc.id
  service_name        = var.proxy_service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.internet_proxy_endpoint.id]
  subnet_ids          = aws_subnet.private.*.id
  private_dns_enabled = false
}

resource "aws_security_group" "internet_proxy_endpoint" {
  name        = "internet_endpoint"
  description = "Control access to the Internet Proxy VPC Endpoint"
  vpc_id      = var.vpc.id
}