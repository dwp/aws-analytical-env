resource "random_id" "emr_bucket_name" {
  byte_length = 16
}

resource "aws_s3_bucket" "emr" {
  bucket = random_id.emr_bucket_name.hex
  acl    = "private"

  tags = var.common_tags

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_alias.emr_s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "emr" {
  bucket = aws_s3_bucket.emr.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
