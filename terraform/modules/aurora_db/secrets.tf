resource "aws_secretsmanager_secret" "master_credentials" {
  name        = "${var.name_prefix}-database/credentials/master"
  description = "${var.name_prefix} master database credentials"

  lifecycle {
    ignore_changes = [tags]
  }

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-database-master" })
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

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-init-db" })
}

resource "aws_secretsmanager_secret" "client_db_credentials" {
  for_each = var.clients

  name        = "${var.name_prefix}-database/credentials/client-${each.key}"
  description = "${var.name_prefix} client ${each.key} database credentials"

  lifecycle {
    ignore_changes = [tags]
  }

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-client-db" })
}

resource "aws_secretsmanager_secret" "sync_rds_credentials" {
  name        = "${var.name_prefix}-database/credentials/sync-rds"
  description = "${var.name_prefix} sync-rds database credentials"

  lifecycle {
    ignore_changes = [tags]
  }

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-sync-rds" })
}

