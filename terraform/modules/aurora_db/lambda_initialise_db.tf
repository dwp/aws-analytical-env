resource "aws_lambda_function" "initialise_database" {
  filename      = "${path.module}/lambda.zip"
  function_name = "${var.name_prefix}-initialise-db"
  role          = aws_iam_role.lambda_manage_mysql_user.arn
  handler       = "initialise_db.handler"
  runtime       = "python3.7"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  timeout                        = 300
  reserved_concurrent_executions = 1
  environment {
    variables = {
      RDS_DATABASE_NAME               = local.database_name
      RDS_CLUSTER_ARN                 = aws_rds_cluster.database_cluster.arn
      RDS_CREDENTIALS_SECRET_NAME     = aws_secretsmanager_secret.initialise_db_credentials.name
      LOG_LEVEL                       = "DEBUG"
    }
  }
  tracing_config {
    mode = "PassThrough"
  }
  tags = merge(
  var.common_tags,
  {
    "Name" = "${var.name_prefix}-manage-mysql-user"
  },
  {
    "ProtectsSensitiveData" = "False"
  },
  )

}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "initialise_db_src"
  output_path = "lambda.zip"
}
