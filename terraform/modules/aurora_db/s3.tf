resource "aws_s3_bucket_object" "init_sql" {
  bucket = var.config_bucket.id
  key    = "${var.name_prefix}-database/init.ddl.sql"
}
