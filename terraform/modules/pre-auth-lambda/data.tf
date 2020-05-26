data "archive_file" "lambda_pre_auth_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/${var.name_prefix}-pre-auth.zip"
}
