resource aws_s3_bucket test_dataset {
  bucket = "${var.name_prefix}_test_dataset_s3"
  tags   = var.common_tags
}

resource aws_s3_bucket_policy test_dataset_s3_policy {
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "BlockHTTP",
        "Effect": "Deny",
        "Principal": {
          "AWS": "*"
        },
        "Action": "*",
        "Resource": [
          "${aws_s3_bucket.test_dataset.arn}/*",
          "${aws_s3_bucket.test_dataset.arn}"
        ],
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  }
  POLICY
  bucket = aws_s3_bucket.test_dataset.id
}

output test_dataset_s3 {
  value = {
    arn = aws_s3_bucket.test_dataset.arn
    id  = aws_s3_bucket.test_dataset.id
  }
}
