resource "aws_lambda_function" "manage_mysql_user" {
  filename      = "${var.manage_mysql_user_lambda_zip["base_path"]}/manage-mysql-user-${var.manage_mysql_user_lambda_zip["version"]}.zip"
  function_name = "${var.name_prefix}-manage-mysql-user"
  role          = aws_iam_role.lambda_manage_mysql_user.arn
  handler       = "manage-mysql-user.handler"
  runtime       = "python3.7"
  source_code_hash = filebase64sha256(
    format(
      "%s/manage-mysql-user-%s.zip",
      var.manage_mysql_user_lambda_zip["base_path"],
      var.manage_mysql_user_lambda_zip["version"],
    ),
  )
  publish = false
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.rotate_password.id]
  }
  timeout                        = 300
  reserved_concurrent_executions = 1
  environment {
    variables = {
      RDS_ENDPOINT                    = aws_rds_cluster.database_cluster.endpoint
      RDS_DATABASE_NAME               = local.database_name
      RDS_MASTER_USERNAME             = local.database_master_username
      RDS_MASTER_PASSWORD_SECRET_NAME = aws_secretsmanager_secret.master_credentials.name
      RDS_CA_CERT                     = "/var/task/AmazonRootCA1.pem" # For Aurora serverless
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
