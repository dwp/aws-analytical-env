/* ========== Batch Service Role ========== */

data aws_iam_policy_document policy_assume_role_batch_service {
  statement {
    sid = "AllowBatchServiceToAssumeRole"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "batch.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "service_role_for_create_metrics_data_batch" {
  name               = "${var.name_prefix}-create-metrics-data-batch-service-role"
  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_batch_service.json
  tags               = merge(var.common_tags, { Name : "${var.name_prefix}-metrics-service-role" })
}

resource "aws_iam_role_policy_attachment" "create_metrics_data_batch_service_role_attachment" {
  role       = aws_iam_role.service_role_for_create_metrics_data_batch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

# Custom policy to allow use of default EBS encryption key by Batch service role
data "aws_iam_policy_document" "aws_batch_service_role_ebs_cmk" {
  statement {
    sid       = "AllowUseDefaultEbsCmk"
    effect    = "Allow"
    resources = [var.default_ebs_kms_key]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

  }

  statement {
    sid       = "AllowGrantDefaultEbsCmk"
    effect    = "Allow"
    actions   = ["kms:CreateGrant"]
    resources = [var.default_ebs_kms_key]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_iam_policy" "aws_batch_service_role_ebs_cmk" {
  name   = "analytical_env_metrics_batch_service_role_ebs_cmk"
  policy = data.aws_iam_policy_document.aws_batch_service_role_ebs_cmk.json
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role_ebs_cmk" {
  role       = aws_iam_role.service_role_for_create_metrics_data_batch.name
  policy_arn = aws_iam_policy.aws_batch_service_role_ebs_cmk.arn
}


/* ========== Batch Instance Role ========== */

data aws_iam_policy_document policy_assume_role_batch_instance {
  statement {
    sid = "AllowBatchJobToAssumeRole"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "instance_role_for_create_metrics_data_batch" {
  name               = "${var.name_prefix}-create-metrics-data-batch-instance-role"
  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_batch_instance.json
  tags               = merge(var.common_tags, { Name : "${var.name_prefix}-metrics-instance-role" })
}

resource "aws_iam_instance_profile" "create_metrics_data_instance_profile" {
  name = "${var.name_prefix}-create-metrics-data-instance-profile"
  role = aws_iam_role.instance_role_for_create_metrics_data_batch.name
}

resource "aws_iam_role_policy_attachment" "policy_attachment_for_create_metrics_instance" {
  role       = aws_iam_role.instance_role_for_create_metrics_data_batch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Custom policy to allow use of default EBS encryption key by Batch instance role
data "aws_iam_policy_document" "ecs_instance_role_batch_ebs_cmk" {
  statement {
    sid    = "AllowUseDefaultEbsCmk"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [var.default_ebs_kms_key]
  }
}

resource "aws_iam_policy" "ecs_instance_role_batch_ebs_cmk" {
  name   = "analytical_env_metrics_batch_instance_role_batch_ebs_cmk"
  policy = data.aws_iam_policy_document.ecs_instance_role_batch_ebs_cmk.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_ebs_cmk" {
  role       = aws_iam_role.instance_role_for_create_metrics_data_batch.name
  policy_arn = aws_iam_policy.ecs_instance_role_batch_ebs_cmk.arn
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_batch_ecr" {
  role       = aws_iam_role.instance_role_for_create_metrics_data_batch.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

/* ========== Batch Job Role ========== */

data aws_iam_policy_document policy_assume_role_batch_job {
  statement {
    sid = "AllowBatchJobToAssumeRole"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
        "batch.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "job_role_for_create_metrics_data_batch" {
  name               = "${var.name_prefix}-create-metrics-data-batch-role"
  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_batch_job.json
  tags               = merge(var.common_tags, { Name : "${var.name_prefix}-metrics-job-role" })
}

data "aws_iam_policy_document" "create_metrics_data_batch_policy" {
  statement {
    sid    = "AllowBatchToUploadToBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObjectTagging"
    ]
    resources = [
      var.dataset_s3.arn,
      "${var.dataset_s3.arn}/*"
    ]
  }

  statement {
    sid    = "AllowGlueActions"
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
      "arn:aws:glue:${var.region}:${var.account}:table/metrics/*",
      "arn:aws:glue:${var.region}:${var.account}:catalog",
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
