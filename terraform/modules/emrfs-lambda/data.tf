data "archive_file" "policy_munge_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/policy-munge-lambda"
  output_path = "${path.module}/${var.name_prefix}-policy-munge.zip"
}
