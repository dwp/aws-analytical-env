output "rds_cluster" {
  value = aws_rds_cluster.database_cluster
}

output "secrets" {
  value = {
    master_credentials = aws_secretsmanager_secret.master_credentials
    client_credentials = merge({
      "initialise_db" = aws_secretsmanager_secret.initialise_db_credentials
      }, {
      for key in var.client_names :
      key => aws_secretsmanager_secret.client_db_credentials[key]
    })
  }
}

output "manage_mysql_user_lambda" {
  value = aws_lambda_function.manage_mysql_user
}

output "initialise_db_lambda" {
  value = aws_lambda_function.initialise_database
}

output "db_name" {
  value = local.database_name
}
