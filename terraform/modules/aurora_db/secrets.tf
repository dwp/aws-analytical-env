resource "aws_secretsmanager_secret" "master_credentials" {
  name        = "${var.name_prefix}-database/credentials/master"
  description = "${var.name_prefix} master database credentials"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_secretsmanager_secret_version" "initial_master_credentials" {
  secret_id = aws_secretsmanager_secret.master_credentials.id
  secret_string = jsonencode({
    "engine"   = "aurora-mysql",
    "username" = aws_rds_cluster.database_cluster.master_username,
    "password" = aws_rds_cluster.database_cluster.master_password
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret" "initialise_db_credentials" {
  name        = "${var.name_prefix}-database/credentials/client-initialise-db"
  description = "${var.name_prefix} initialise-db database credentials"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_secretsmanager_secret" "client_db_credentials" {
  for_each = var.client_names

  name        = "${var.name_prefix}-database/credentials/client-${each.value}"
  description = "${var.name_prefix} client ${each.value} database credentials"

  lifecycle {
    ignore_changes = [tags]
  }
}
