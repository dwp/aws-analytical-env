resource "random_id" "emr_bucket_name" {
  byte_length = 16
}

resource "aws_s3_bucket" "emr" {
  bucket = random_id.emr_bucket_name.hex
  acl    = "private"

  tags = merge({ "Name" = "${var.emr_cluster_name}-emr-s3" }, var.common_tags)

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



resource "random_id" "hive_data_bucket_name" {
  byte_length = 16
}

resource "aws_s3_bucket" "hive_data" {
  bucket = random_id.hive_data_bucket_name.hex
  acl    = "private"

  tags = merge({ "Name" = "${var.emr_cluster_name}-hive-data-s3" }, var.common_tags)

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_alias.hive_data_s3.arn
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
    target_prefix = "S3Logs/${var.name_prefix}-hive_data-s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "hive_data" {
  bucket = aws_s3_bucket.hive_data.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

data "aws_iam_policy_document" "hive_data_bucket_https_only" {
  statement {
    sid     = "BlockHTTP"
    effect  = "Deny"
    actions = ["*"]

    resources = [
      aws_s3_bucket.hive_data.arn,
      "${aws_s3_bucket.hive_data.arn}/*",
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

resource "aws_s3_bucket_policy" "hive_data_bucket_https_only" {
  depends_on = [aws_s3_bucket.hive_data]
  bucket     = aws_s3_bucket.hive_data.id
  policy     = data.aws_iam_policy_document.hive_data_bucket_https_only.json
}

resource "aws_s3_bucket_object" "hive_data_bucket_group_folders" {
  depends_on = [aws_s3_bucket.hive_data]

  for_each     = data.aws_iam_policy_document.group_hive_data_access_documents
  bucket       = aws_s3_bucket.hive_data.id
  key          = "${each.key}/"
  content_type = "application/x-directory"

  tags = merge({ "Name" = "${var.emr_cluster_name}-hive-data-s3" }, var.common_tags)
}

resource "aws_s3_bucket_object" "hive_auth_provider_jar" {
  bucket = aws_s3_bucket.emr.id
  key    = "jars/hive-custom-auth.jar"
  source = var.hive_custom_auth_provider_path

  tags = merge({ "Name" = "${var.name_prefix}-hive-auth-provider-jar" }, var.common_tags)

}

