resource "aws_iam_role" "emrfs_iam" {
  name               = "emrfs_iam"
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
  role       =  aws_iam_role.emrfs_iam.name
  policy_arn =  "arn:aws:iam::${var.account}:policy/AnalyticalDatasetReadOnly"
}


resource "aws_iam_role_policy" "emrfs_iam" {
  name   = "emrfs_iam"
  role   = aws_iam_role.emrfs_iam.id
  policy = data.aws_iam_policy_document.emrfs_iam.json
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

  statement {
    sid    = "AllowS3Read"
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*"
    ]

    resources = concat(
      [
        for path_tuple in var.dataset_s3_paths :
        format("arn:aws:s3:::%s/%s", path_tuple[0], path_tuple[1])
      ]
    )

    condition {
      test     = "StringEquals"
      variable = format("s3:ExistingObjectTag/%s", var.dataset_s3_tags[0])

      values = [
        var.dataset_s3_tags[1]
      ]
    }
  }
}
