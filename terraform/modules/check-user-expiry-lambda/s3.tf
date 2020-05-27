resource "aws_s3_bucket" "check_user_expiry_email" {
  bucket = "${var.name_prefix}-check-user-expiry-email"
  acl    = "private"
  tags   = merge(var.common_tags, { Name = "${var.name_prefix}-check-user-expiry" })

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_alias.key_s3_check_user_expiry_email.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "check_user_expiry_email" {
  bucket = aws_s3_bucket.check_user_expiry_email.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_object" "check_user_expiry_email_from" {
  bucket  = aws_s3_bucket.check_user_expiry_email
  key     = "email_from.txt"
  content = templatefile("${path.module}/s3_objects/email_from.txt.tpl", { email_address_dataworks_access_management = var.from_email_address })
}

resource "aws_s3_bucket_object" "check_user_expiry_email_subject" {
  bucket = aws_s3_bucket.check_user_expiry_email
  key    = "email_subject.txt"
  source = "${path.module}/s3_objects/email_subject.txt"
  etag   = filemd5("${path.module}/s3_objects/email_subject.txt")
}

resource "aws_s3_bucket_object" "check_user_expiry_email_body" {
  bucket = aws_s3_bucket.check_user_expiry_email
  key    = "email_body.txt"
  source = "${path.module}/s3_objects/email_body.txt"
  etag   = filemd5("${path.module}/s3_objects/email_body.txt")
}
