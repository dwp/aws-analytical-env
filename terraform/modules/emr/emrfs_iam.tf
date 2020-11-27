resource "aws_iam_role" "emrfs_iam" {
  for_each           = toset(flatten([for name, policy_suffix in var.security_configuration_groups : name]))
  name               = each.value
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

resource "aws_iam_policy" "emrfs_iam" {
  name   = "emrfs_iam"
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

locals {
  user_policies = flatten([
    for group, policy_suffixes in var.security_configuration_groups : [
      {
        group      = group
        policy_arn = aws_iam_policy.emrfs_iam.arn
      },
      [
        for policy_suffix in policy_suffixes :
        {
          group      = group
          policy_arn = "arn:aws:iam::${var.account}:policy/${join("", regexall("[a-zA-Z0-9]", policy_suffix))}"
        }
      ]
    ]
  ])

}

resource "aws_iam_role_policy_attachment" "attach_policies_to_roles" {
  depends_on = [aws_iam_policy.group_hive_data_access_policy]
  count      = length(local.user_policies)
  role       = aws_iam_role.emrfs_iam[local.user_policies[count.index].group].name
  policy_arn = local.user_policies[count.index].policy_arn
}
