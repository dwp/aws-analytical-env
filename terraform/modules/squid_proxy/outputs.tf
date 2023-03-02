output "proxy_vpce_service" {
  value       = aws_vpc_endpoint_service.internet_proxy
  description = "Exposes attributes of internet proxy endpoint service."
}
