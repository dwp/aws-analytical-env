output "internet_proxy_service" {
  value = {
    service_name = aws_vpc_endpoint_service.internet_proxy.service_name
  }
}
