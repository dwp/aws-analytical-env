resource "aws_s3_bucket_object" "init_sql" {
  bucket = var.config_bucket.id
  key    = "${var.name_prefix}-database/init.ddl.sql"

  content_base64 = base64encode(file(var.init_db_sql_path))

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-init-sql" })
}
