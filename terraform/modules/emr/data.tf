data "aws_route53_zone" "main" {
  provider = aws.management

  name = var.parent_domain_name
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "archive_file" "emr_scheduled_scaling_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/emr-scheduled-scaling-lambda-files"
  output_path = "${path.module}/${var.name_prefix}-emr-scheduled-scaling.zip"
}

data "aws_ec2_managed_prefix_list" "list" {
  name = "dwp-*-aws-cidrs-*"
}