data "aws_region" "current" {}

data "aws_ecs_cluster" "ecs_main_cluster" {
  cluster_name = "main"
}

data "aws_route53_zone" "main" {
  provider = aws.management

  name = var.parent_domain_name
}
