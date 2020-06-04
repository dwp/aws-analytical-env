resource "aws_dynamodb_table" "dynamodb_table_user" {
  name         = "analytical-frontend-service-user"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "username"
  tags         = merge(var.common_tags, { Name = "${var.name_prefix}-pre-auth", "ProtectSensitiveData" = "True" })

  attribute {
    name = "username"
    type = "S"
  }
}
