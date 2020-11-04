data "aws_region" "current" {
}

data "aws_availability_zones" "available" {
}

data "aws_caller_identity" "current" {
}

data "aws_route53_zone" "main" {
  provider = aws.management

  name = var.parent_domain_name
}

data "aws_ecs_cluster" "ecs_main_cluster" {
  cluster_name = var.ecs_cluster_name
}
