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

data "terraform_remote_state" "internal_compute" {
  backend   = "s3"
  workspace = terraform.workspace

  config = {
    bucket         = "{{terraform.state_file_bucket}}"
    key            = "terraform/dataworks/aws-internal-compute.tfstate"
    region         = "{{terraform.state_file_region}}"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:{{terraform.state_file_region}}:{{terraform.state_file_account}}:key/{{terraform.state_file_kms_key}}"
    dynamodb_table = "remote_state_locks"
  }
}