data "archive_file" "lambda_check_user_expiry_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/${var.name_prefix}-check-user-expiry.zip"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
