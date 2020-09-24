resource "random_id" "emr_bucket_name" {
  byte_length = 16
}

resource "aws_s3_bucket" "emr" {
  bucket = random_id.emr_bucket_name.hex
  acl    = "private"

  tags = merge({ "Name" = "${var.emr_cluster_name}-s3-bucket" }, var.common_tags)

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
  lifecycle_rule {
    id      = ""
    prefix  = "/"
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }

  logging {
    target_bucket = var.logging_bucket
    target_prefix = "S3Logs/${var.name_prefix}-emr-s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "emr" {
  bucket = aws_s3_bucket.emr.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

data "aws_iam_policy_document" "config_bucket_https_only" {
  statement {
    sid     = "BlockHTTP"
    effect  = "Deny"
    actions = ["*"]

    resources = [
      aws_s3_bucket.emr.arn,
      "${aws_s3_bucket.emr.arn}/*",
    ]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}

resource "aws_s3_bucket_policy" "config_bucket_https_only" {
  bucket = aws_s3_bucket.emr.id
  policy = data.aws_iam_policy_document.config_bucket_https_only.json
}
