output "internet_proxy_service" {
  value = {
    service_name = aws_vpc_endpoint_service.internet_proxy.service_name
    lb_listener  = aws_lb_listener.container_internet_proxy_tls
  }
}
