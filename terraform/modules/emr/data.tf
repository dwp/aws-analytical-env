data "aws_route53_zone" "main" {
  provider = aws.management

  name = var.parent_domain_name
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
