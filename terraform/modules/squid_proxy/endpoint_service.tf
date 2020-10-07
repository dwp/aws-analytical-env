resource "aws_vpc_endpoint_service" "internet_proxy" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.container_internet_proxy.arn]
  tags                       = var.common_tags
}

resource "aws_vpc_endpoint_service_allowed_principal" "managed_envs" {
  for_each                = var.managed_envs_account_numbers
  vpc_endpoint_service_id = aws_vpc_endpoint_service.internet_proxy.id
  principal_arn           = format("arn:aws:iam::%s:root", each.value)
}

resource "aws_vpc_endpoint_service_allowed_principal" "management" {
  vpc_endpoint_service_id = aws_vpc_endpoint_service.internet_proxy.id
  principal_arn           = format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)
}
