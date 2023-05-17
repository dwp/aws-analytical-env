data "local_file" "batch_config_hcs" {
  filename = "${path.module}files/batch/batch_config_hcs.sh"
}

resource "aws_s3_object" "batch_config_hcs" {
  bucket     = var.common_config_bucket
  key        = "component/metrics_batch/batch_config_hcs"
  content    = data.local_file.batch_config_hcs.content
  kms_key_id = var.common_config_bucket_cmk_arn

  tags = merge(
    var.common_tags,
    {
      Name = "batch-config-hcs"
    },
  )
}

data "local_file" "batch_logrotate_script" {
  filename = "${path.module}files/batch/batch.logrotate"
}

resource "aws_s3_object" "batch_logrotate_script" {
  bucket     = var.common_config_bucket
  key        = "component/metrics_batch/batch.logrotate"
  content    = data.local_file.batch_logrotate_script.content
  kms_key_id = var.common_config_bucket_cmk_arn

  tags = merge(
    var.common_tags,
    {
      Name = "batch-logrotate-script"
    },
  )
}

data "local_file" "batch_cloudwatch_script" {
  filename = "${path.module}files/batch/batch_cloudwatch.sh"
}

resource "aws_s3_object" "batch_cloudwatch_script" {
  bucket     = var.common_config_bucket
  key        = "component/metrics_batch/batch_cloudwatch.sh"
  content    = data.local_file.batch_cloudwatch_script.content
  kms_key_id = var.common_config_bucket_cmk_arn

  tags = merge(
    var.common_tags,
    {
      Name = "batch-cloudwatch-script"
    },
  )
}

data "local_file" "batch_logging_script" {
  filename = "${path.module}files/batch/batch_logging.sh"
}

resource "aws_s3_object" "batch_logging_script" {
  bucket     = var.common_config_bucket
  key        = "component/metrics_batch/batch_logging.sh"
  content    = data.local_file.batch_logging_script.content
  kms_key_id = var.common_config_bucket_cmk_arn

  tags = merge(
    var.common_tags,
    {
      Name = "batch-logging-script"
    },
  )
}