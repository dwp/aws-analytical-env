resource "aws_secretsmanager_secret" "master_credentials" {
  name        = "${var.name_prefix}-master-rds-credentials"
  description = "${var.name_prefix} master database credentials"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_secretsmanager_secret" "initialise_db_credentials" {
  name        = "${var.name_prefix}-initialise-db-rds-credentials"
  description = "${var.name_prefix} initialise-db database credentials"

  lifecycle {
    ignore_changes = [tags]
  }
}
