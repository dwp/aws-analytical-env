resource "aws_iam_role" "emrfs_iam" {
  name               = "emrfs_iam"
  assume_role_policy = data.aws_iam_policy_document.emrfs_iam_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role" "emrfs_iam_non_pii" {
  name               = "emrfs_iam_non_pii"
  assume_role_policy = data.aws_iam_policy_document.emrfs_iam_assume_role.json
  tags               = var.common_tags
}

data "aws_iam_policy_document" "emrfs_iam_assume_role" {
  statement {
    sid     = "AllowAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.emr_ec2_role.arn
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "AnalyticalDatasetReadOnly" {
  role       = aws_iam_role.emrfs_iam.name
  policy_arn = "arn:aws:iam::${var.account}:policy/AnalyticalDatasetCrownReadOnly"
}

resource "aws_iam_role_policy" "emrfs_iam" {
  name   = "emrfs_iam"
  role   = aws_iam_role.emrfs_iam.id
  policy = data.aws_iam_policy_document.emrfs_iam.json
}

resource "aws_iam_role_policy" "emrfs_iam_non_pii" {
  name   = "emrfs_iam_non_pii"
  role   = aws_iam_role.emrfs_iam_non_pii.id
  policy = data.aws_iam_policy_document.emrfs_iam_non_pii.json
}

data "aws_iam_policy_document" "emrfs_iam" {
  statement {
    sid    = "AllowAllDynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:*",
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "emrfs_iam_non_pii" {
  statement {
    sid    = "AllowAllDynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:*",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      "${var.dataset_s3_paths[0]}/analytical-dataset/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "${var.dataset_s3_paths[0]}/analytical-dataset/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/Pii"

      values = [
        "false"
      ]
    }
  }
}
