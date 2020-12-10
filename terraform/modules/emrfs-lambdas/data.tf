data "archive_file" "policy_munge_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/policy-munge-lambda-files"
  output_path = "${path.module}/${var.name_prefix}-policy-munge.zip"
}

data "archive_file" "cognito_rds_sync_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/cognito-rds-sync-lambda-files"
  output_path = "${path.module}/${var.name_prefix}-cognito-rds-sync.zip"
}
