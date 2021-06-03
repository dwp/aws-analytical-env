resource "random_id" "jupyter_bucket" {
  byte_length = 16
}

resource "aws_s3_bucket" "jupyter_storage" {
  bucket = random_id.jupyter_bucket.hex
  acl    = "private"

  tags = merge(var.common_tags, { Name = "OSJupyterUserStorage", "ProtectSensitiveData" = "True" })

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "${var.name_prefix}-lifecycle"
    enabled = true
    noncurrent_version_expiration {
      days = 30
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.jupyter_bucket_master_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  logging {
    target_bucket = var.logging_bucket
    target_prefix = "S3Logs/${var.name_prefix}"
  }
}

resource "aws_s3_bucket_public_access_block" "jupyter_bucket" {
  depends_on = [aws_s3_bucket.jupyter_storage]
  bucket     = aws_s3_bucket.jupyter_storage.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
