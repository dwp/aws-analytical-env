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
  role       = aws_iam_role.emrfs_iam.name
  policy_arn = "arn:aws:iam::${var.account}:policy/AnalyticalDatasetReadOnly"
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
}
