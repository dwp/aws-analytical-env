resource "random_id" "password_salt" {
  byte_length = 16
}

locals {
  database_name = replace(
    replace(var.name_prefix, "-", "_"),
    "/[\\/?%*:|\"<>.]*/",
    ""
  )
  database_master_username = "master"
  database_master_password = substr(random_id.password_salt.hex, 0, 16)
}
