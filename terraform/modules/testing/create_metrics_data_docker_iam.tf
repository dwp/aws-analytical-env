/* ========== Batch Service Role ========== */

data aws_iam_policy_document policy_assume_role_batch_service {
  statement {
    sid = "AllowBatchServiceToAssumeRole"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = [
        "batch.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "service_role_for_create_metrics_data_batch" {
  name               = "${var.name_prefix}-create-metrics-data-batch-instance-role"
  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_batch_service.json
}

resource "aws_iam_role_policy_attachment" "create_metrics_data_batch_service_role_attachment" {
  role       = aws_iam_role.service_role_for_create_metrics_data_batch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

/* ========== Batch Instance Role ========== */

data aws_iam_policy_document policy_assume_role_batch_instance {
  statement {
    sid = "AllowBatchJobToAssumeRole"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "instance_role_for_create_metrics_data_batch" {
  name               = "${var.name_prefix}-create-metrics-data-batch-instance-role"
  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_batch_instance.json
}

resource "aws_iam_instance_profile" "create_metrics_data_instance_profile" {
  name = "${var.name_prefix}-create-metrics-data-instance-profile"
  role = aws_iam_role.instance_role_for_create_metrics_data_batch.arn
}

resource "aws_iam_role_policy_attachment" "policy_attachment_for_create_metrics_instance" {
  role       = aws_iam_role.instance_role_for_create_metrics_data_batch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerRegistryReadOnly"
}

/* ========== Batch Job Role ========== */

data aws_iam_policy_document policy_assume_role_batch_job {
  statement {
    sid = "AllowBatchJobToAssumeRole"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = [
        "ecs-task.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "job_role_for_create_metrics_data_batch" {
  name               = "${var.name_prefix}-create-metrics-data-batch-role"
  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_batch_job.json
}

data "aws_iam_policy_document" "create_metrics_data_batch_policy" {
  statement {
    sid    = "AllowLambdaToUploadToBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListObjects",
    ]
    resources = [
      "arn:aws:s3:::${var.dataset_s3.arn}",
      "arn:aws:s3:::${var.dataset_s3.arn}/*"
    ]
  }

  statement {
    sid = "AllowGlueActions"
    effect = "Allow"
    actions = [
      "glue:DeleteTable",
      "glue:CreateTable",
      "glue:CreateDatabase",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
    ]
    resources = [
      "arn:aws:glue:${var.region}:${var.account}:database/metrics",
      "arn:aws:glue:${var.region}:${var.account}:table/metrics/*"
    ]
  }

  statement {
    sid    = "KmsToAccessBucket"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      var.published_bucket_cmk
    ]
  }
}

resource "aws_iam_policy" "policy_for_create_metrics_data_batch" {
  policy = data.aws_iam_policy_document.create_metrics_data_batch_policy.json
}

resource "aws_iam_role_policy_attachment" "policy_attachment_for_create_metrics_data_batch" {
  role       = aws_iam_role.job_role_for_create_metrics_data_batch.name
  policy_arn = aws_iam_policy.policy_for_create_metrics_data_batch.arn
}

resource "aws_iam_role_policy_attachment" "default_policy_attachment_for_create_metrics_data_batch" {
  role       = aws_iam_role.job_role_for_create_metrics_data_batch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
