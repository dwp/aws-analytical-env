resource "aws_iam_role" "emr_role" {
  name               = "AE_EMR_Role"
  assume_role_policy = data.aws_iam_policy_document.emr_role_assume_role.json
  tags               = var.common_tags
}

data "aws_iam_policy_document" "emr_role_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "elastic_map_reduce_role" {
  name   = "AE_ElasticMapReduceRole"
  role   = aws_iam_role.emr_role.id
  policy = data.aws_iam_policy_document.elastic_map_reduce_role.json
}

data "aws_iam_policy_document" "elastic_map_reduce_role" {
  #### DW-4076 Pemissions no longer required
  # "iam:GetRole",
  # "iam:GetRolePolicy",
  # "iam:ListInstanceProfiles",
  # "iam:ListRolePolicies",
  # "iam:PassRole",
  # "sdb:BatchPutAttributes",
  # "sdb:Select",
  # "sqs:CreateQueue",
  # "sqs:Delete*",
  # "sqs:GetQueue*",
  # "sqs:PurgeQueue",
  # "sqs:ReceiveMessage",
  # "cloudwatch:PutMetricAlarm",
  # "cloudwatch:DescribeAlarms",
  # "cloudwatch:DeleteAlarms",
  # "application-autoscaling:RegisterScalableTarget",
  # "application-autoscaling:DeregisterScalableTarget",
  # "application-autoscaling:PutScalingPolicy",
  # "application-autoscaling:DeleteScalingPolicy",
  # "application-autoscaling:Describe*"
  statement {
    sid    = "EC2-Allow"
    effect = "Allow"
    // TODO restrict globs
    actions = [
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CancelSpotInstanceRequests",
      "ec2:CreateNetworkInterface",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteNetworkInterface",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteTags",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstances",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribePrefixLists",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotInstanceRequests",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeVpcEndpointServices",
      "ec2:DescribeVpcs",
      "ec2:DetachNetworkInterface",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:RequestSpotInstances",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:DeleteVolume",
      "ec2:DescribeVolumeStatus",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Application"
      values = [
        "aws-analytical-env"
      ]
    }
  }

  statement {
    sid    = "KMS-Allow"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]
    resources = [
      aws_kms_key.emr_ebs.arn,
      aws_kms_key.emr_s3.arn
    ]
  }

  statement {
    sid    = "S3-Allow"
    effect = "Allow"
    // TODO restrict
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.emr.id}",
      "arn:aws:s3:::${aws_s3_bucket.emr.id}/*"
    ]
  }

  statement {
    sid       = "Create-service-linked-role-allow"
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["arn:aws:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot*"]
    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["spot.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "emr_ec2_role" {
  name               = "AE_EMR_EC2_Role"
  assume_role_policy = data.aws_iam_policy_document.emr_ec2_role_assume_role.json
  tags               = var.common_tags
}

data "aws_iam_policy_document" "emr_ec2_role_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "emr_ec2_role" {
  name = aws_iam_role.emr_ec2_role.name
  role = aws_iam_role.emr_ec2_role.name
}

resource "aws_iam_role_policy" "elastic_map_reduce_for_ec2_role" {
  name   = "AE_ElasticMapReduceforEC2Role"
  role   = aws_iam_role.emr_ec2_role.id
  policy = data.aws_iam_policy_document.elastic_map_reduce_for_ec2_role.json
}

data aws_iam_policy_document elastic_map_reduce_for_ec2_role {
  ### DW-4076 Permissions no longer required
  # "cloudwatch:*",
  # "ec2:Describe*",
  # "elasticmapreduce:Describe*",
  # "elasticmapreduce:ListBootstrapActions",
  # "elasticmapreduce:ListClusters",
  # "elasticmapreduce:ListInstanceGroups",
  # "elasticmapreduce:ListInstances",
  # "elasticmapreduce:ListSteps",
  # "kinesis:CreateStream",
  # "kinesis:DeleteStream",
  # "kinesis:DescribeStream",
  # "kinesis:GetRecords",
  # "kinesis:GetShardIterator",
  # "kinesis:MergeShards",
  # "kinesis:PutRecord",
  # "kinesis:SplitShard",
  # "rds:Describe*",
  # "sdb:*",
  # "sns:*",
  # "sqs:*",
  statement {
    sid    = "Glue-Allow"
    effect = "Allow"
    actions = [
      "glue:CreateDatabase",
      "glue:UpdateDatabase",
      "glue:DeleteDatabase",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:DeleteTable",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetTableVersions",
      "glue:CreatePartition",
      "glue:BatchCreatePartition",
      "glue:UpdatePartition",
      "glue:DeletePartition",
      "glue:BatchDeletePartition",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition",
      "glue:CreateUserDefinedFunction",
      "glue:UpdateUserDefinedFunction",
      "glue:DeleteUserDefinedFunction",
      "glue:GetUserDefinedFunction",
      "glue:GetUserDefinedFunctions"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "glue:ResourceTag/Application"
      values = [
        "aws-analytical-env"
      ]
    }
  }

  statement {
    sid    = "Glue-Deny"
    effect = "Deny"
    actions = [
      "glue:*"
    ]
    resources = [
      "arn:aws:glue:*:*:database/manifestetl",
    ]
  }

  statement {
    sid    = "Dynamodb-Allow"
    effect = "Allow"
    actions = [
      "dynamodb:*",
    ]
    ## TODO restrict
    resources = ["*"]
  }

  statement {
    sid    = "Acm-export-allow"
    effect = "Allow"
    actions = [
      "acm:ExportCertificate",
    ]
    resources = [
      aws_acm_certificate.emr.arn
    ]
  }

  statement {
    sid    = "PrivateCA-get-certificate-allow"
    effect = "Allow"
    actions = [
      "acm-pca:GetCertficate"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "KMS-Allow"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]
    resources = [
      aws_kms_key.emr_ebs.arn,
      aws_kms_key.emr_s3.arn
    ]
  }

  statement {
    sid    = "S3-Allow"
    effect = "Allow"
    // TODO restrict
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.emr.id}",
      "arn:aws:s3:::${aws_s3_bucket.emr.id}/*",
      "arn:aws:s3:::eu-west-2.elasticmapreduce",
      "arn:aws:s3:::eu-west-2.elasticmapreduce/*",
      "arn:aws:s3:::${var.env_certificate_bucket}",
      "arn:aws:s3:::${var.env_certificate_bucket}/*",
      "arn:aws:s3:::dw-management-dev-public-certificates",
      "arn:aws:s3:::dw-management-dev-public-certificates/*"
    ]
  }

  statement {
    sid    = "AllowAssumeReadOnlyCognitoRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [aws_iam_role.cogntio_read_only_role.arn]
  }

}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.emr_ec2_role.name
}

resource aws_iam_role_policy amazon_ec2_role_for_ssm {
  role   = aws_iam_role.emr_ec2_role.name
  policy = data.aws_iam_policy_document.amazon_ec2_role_for_ssm.json
}

data aws_iam_policy_document amazon_ec2_role_for_ssm {
  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstanceStatus"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ds:CreateComputer",
      "ds:DescribeDirectories"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "emr_to_ecr" {
  name   = "AE_AllowReadAccessECR"
  role   = aws_iam_role.emr_ec2_role.name
  policy = data.aws_iam_policy_document.emr_to_ecr.json
}

data "aws_iam_policy_document" "emr_to_ecr" {
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
    resources = ["arn:aws:ecr:*:*:repository/aws-analytical-env/*"]
  }
}

resource "aws_iam_role" "emr_autoscaling_role" {
  name               = "AE_EMR_AutoScaling_Role"
  assume_role_policy = data.aws_iam_policy_document.emr_autoscaling_role_assume_role.json
  tags               = var.common_tags
}

data "aws_iam_policy_document" "emr_autoscaling_role_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "elasticmapreduce.amazonaws.com",
        "application-autoscaling.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "elastic_map_reduce_for_auto_scaling_role" {
  name   = "AE_ElasticMapReduceforAutoScalingRole"
  role   = aws_iam_role.emr_autoscaling_role.id
  policy = data.aws_iam_policy_document.elastic_map_reduce_for_auto_scaling_role.json
}

data "aws_iam_policy_document" "elastic_map_reduce_for_auto_scaling_role" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:DescribeAlarms",
      "elasticmapreduce:ListInstanceGroups",
      "elasticmapreduce:ModifyInstanceGroups"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "cogntio_read_only_role" {
  provider           = aws.management
  assume_role_policy = data.aws_iam_policy_document.assume_role_cross_acount.json

  tags = merge(var.common_tags, {
    Name = "allow-read-only-cognito"
  })
}

data "aws_iam_policy_document" "assume_role_cross_acount" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [data.aws_caller_identity.current.account_id]
      type        = "AWS"
    }

    condition {
      variable = "aws:PrincipalArn"
      test     = "ArnEquals"
      values   = [aws_iam_role.emr_ec2_role.arn]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ReadOnlyCognito" {
  provider = aws.management

  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoReadOnly"
  role       = aws_iam_role.cogntio_read_only_role.name
}
