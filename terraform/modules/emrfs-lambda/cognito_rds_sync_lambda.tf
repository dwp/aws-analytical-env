resource "aws_lambda_function" "cognito_rds_sync_lambda" {
  filename         = data.archive_file.cognito_rds_sync_lambda_zip.output_path
  function_name    = "${var.name_prefix}-cognito-rds-sync"
  role             = aws_iam_role.cognito_rds_sync_lambda_role.arn
  handler          = "lambda_handler.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.cognito_rds_sync_lambda_zip.output_base64sha256
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-cognito-rds-sync", "ProtectSensitiveData" = "False" })
  timeout          = 60

  environment {
    variables = {
      DATABASE_CLUSTER_ARN  = var.db_cluster_arn
      DATABASE_NAME         = var.db_name
      SECRET_ARN            = var.db_client_secret_arn
      COGNITO_USERPOOL_ID   = var.cognito_user_pool_id
      MGMT_ACCOUNT_ROLE_ARN = aws_iam_role.mgmt_rbac_lambda_role.arn
    }
  }

  depends_on = [data.archive_file.cognito_rds_sync_lambda_zip]
}
