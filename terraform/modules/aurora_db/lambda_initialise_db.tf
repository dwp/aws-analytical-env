resource "aws_lambda_function" "initialise_database" {
  filename         = "${path.module}/lambda.zip"
  function_name    = "${var.name_prefix}-initialise-db"
  role             = aws_iam_role.lambda_initialise_db.arn
  handler          = "initialise_db.handler"
  runtime          = "python3.7"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout                        = 300
  reserved_concurrent_executions = 1
  environment {
    variables = {
      RDS_DATABASE_NAME          = local.database_name
      RDS_CLUSTER_ARN            = aws_rds_cluster.database_cluster.arn
      RDS_CREDENTIALS_SECRET_ARN = aws_secretsmanager_secret.initialise_db_credentials.arn
      INIT_SQL_S3_BUCKET         = aws_s3_bucket_object.init_sql.bucket
      INIT_SQL_S3_KEY            = aws_s3_bucket_object.init_sql.key
      LOG_LEVEL                  = "DEBUG"
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

  depends_on = [data.archive_file.lambda_zip]
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/initialise_db_src"
  output_path = "${path.module}/lambda.zip"
}
