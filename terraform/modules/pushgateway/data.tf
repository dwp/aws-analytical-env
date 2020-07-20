data "aws_region" "current" {}

data "aws_ecs_cluster" "ecs_main_cluster" {
  cluster_name = "main"
}

data "aws_acm_certificate" "lb" {
  domain = var.lb_fqdn
}

