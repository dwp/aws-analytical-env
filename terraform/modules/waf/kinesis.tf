resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "aws-waf-logs-${local.name}-firehose"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    prefix     = "waf/${local.name}/"
    bucket_arn = var.log_bucket
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/aws-waf-logs-${local.name}-firehose"
      log_stream_name = "S3Delivery"
    }
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "${local.name}-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}

resource "aws_iam_policy" "write_s3_firehose" {
  name        = "${var.name}_WriteFirehose"
  description = "Allow Ingestion EMR cluster to write HBase data to the input bucket"
  policy      = data.aws_iam_policy_document.write_s3_firehose.json
}

resource "aws_iam_role_policy_attachment" "write_s3_firehose" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.write_s3_firehose.arn
}

data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "write_s3_firehose" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      var.log_bucket
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject*",
      "s3:GetObject*",
      "s3:DeleteObject*",
    ]
    resources = [
      "${var.log_bucket}/waf/*"
    ]
  }
}
