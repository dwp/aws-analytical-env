data "aws_iam_policy_document" "jupyter_bucket_restrict_to_vpc" {
  statement {
    sid    = "${var.name_prefix}-RestrictToVPC"
    effect = "Deny"
    actions = [
      "s3:*",
    ]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    resources = [
      "${aws_s3_bucket.jupyter_storage.arn}/*"
    ]

    condition {
      test = "StringNotEquals"
      values = [
        var.vpc_id
      ]
      variable = "aws:sourceVpc"
    }
  }
  statement {
    sid     = "BlockHTTP"
    effect  = "Deny"
    actions = ["*"]
    resources = [
      "${aws_s3_bucket.jupyter_storage.arn}",
      "${aws_s3_bucket.jupyter_storage.arn}/*",
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}

data "aws_iam_policy_document" "jupyter_bucket_kms_key" {

  statement {
    sid    = "EnableIAMPermissionsBreakglass"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_user.breakglass.arn]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid       = "EnableIAMPermissionsCI"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      identifiers = [data.aws_iam_role.ci.arn]
      type        = "AWS"
    }
  }

  statement {
    sid    = "DenyCIEncryptDecrypt"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.ci.arn]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ImportKeyMaterial",
      "kms:ReEncryptFrom",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "EnableIAMPermissionsAdministrator"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.administrator.arn]
    }

    actions = [
      "kms:Describe*",
      "kms:List*",
      "kms:Get*",
      "kms:*" //temp for local testing
    ]

    resources = ["*"]
  }

  statement {
    sid    = "EnableKeyUsagePermissionsRoot"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account}:root"]
    }

    actions = [
      "kms:*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "EnableAWSConfigManagerScanForSecurityHub"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.aws_config.arn]
    }

    actions = [
      "kms:Describe*",
      "kms:Get*",
      "kms:List*"
    ]

    resources = ["*"]
  }
}


resource "aws_s3_bucket_policy" "jupyter_bucket" {
  bucket = aws_s3_bucket.jupyter_storage.id
  policy = data.aws_iam_policy_document.jupyter_bucket_restrict_to_vpc.json
}
