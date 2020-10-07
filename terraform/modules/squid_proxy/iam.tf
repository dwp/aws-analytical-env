data "aws_iam_policy_document" "container_internet_proxy_read_config" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      var.config_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${var.config_bucket.arn}/${local.squid_config_s3_main_prefix}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
    ]

    resources = [
      var.config_bucket.cmk_arn,
    ]
  }
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    sid = "AllowECSTasksAssumeRole"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }

}

resource "aws_iam_role" "proxy" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy" "proxy" {
  policy = data.aws_iam_policy_document.container_internet_proxy_read_config.json
  role   = aws_iam_role.proxy.id
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
