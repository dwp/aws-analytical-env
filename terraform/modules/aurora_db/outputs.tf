output "rds_cluster" {
  value = aws_rds_cluster.database_cluster
}

output "secrets" {
  value = {
    master_credentials = aws_secretsmanager_secret.master_credentials
    initialise_db      = aws_secretsmanager_secret.initialise_db_credentials
  }
}
