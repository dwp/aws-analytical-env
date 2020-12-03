resource "aws_secretsmanager_secret" "master_credentials" {
  name        = "${var.name_prefix}-master-rds-credentials"
  description = "${var.name_prefix} master database credentials"

  lifecycle {
    ignore_changes = [tags]
  }
}
