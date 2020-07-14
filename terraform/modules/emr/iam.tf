# EMR Service Role
resource "aws_iam_role" "emr_role" {
  name               = "AE_EMR_Role"
  assume_role_policy = data.aws_iam_policy_document.emr_role_assume_role.json
  tags               = var.common_tags
}

data "aws_iam_policy_document" "emr_role_assume_role" {
  statement {
    sid     = "AllowEMRToAssumeRole"
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
  statement {
    sid    = "AllowEmrToCreateClusters"
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CancelSpotInstanceRequests",
      "ec2:CreateNetworkInterface",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
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
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:RequestSpotInstances",
      "ec2:RunInstances",
      "ec2:DescribeVolumeStatus",
      "ec2:DescribeVolumes",
      "application-autoscaling:DescribeScalableTargets",
      "ec2:DeleteNetworkInterface",
    ]
    # Majority of these actions don't accept conditions or resource restriction
    resources = ["*"]
  }

  statement {
    sid    = "AllowEmrToDestroyOwnCluster"
    effect = "Allow"
    actions = [
      "ec2:DetachVolume",
      "ec2:DeleteVolume",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteTags",
      "ec2:DetachNetworkInterface",
      "ec2:TerminateInstances",
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${var.account}:*"
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Application"
      values = [
        "aws-analytical-env"
      ]
    }
  }

  statement {
    sid    = "AllowEmrReadRolesAndPoliciesAllow"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListInstanceProfiles",
      "iam:ListRolePolicies",
      "iam:PassRole"
    ]
    resources = [
      aws_iam_role.emr_ec2_role.arn,
      aws_iam_instance_profile.emr_ec2_role.arn
    ]
  }

  statement {
    sid    = "AllowEmrToCreateMetricsAndAlarms"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DeleteAlarms",
    ]
    resources = [
      "arn:aws:cloudwatch:${var.region}:${var.account}:alarm:*"
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Application"
      values = [
        "aws-analytical-env"
      ]
    }
  }

  statement {
    sid    = "AllowEmrToUseSpecificKMSKeys"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant" #Required by EMR to spin up instances
    ]
    resources = [
      aws_kms_key.emr_ebs.arn,
      aws_kms_key.emr_s3.arn,
    ]
  }

  statement {
    sid    = "AllowEmrToReadEmrBucket"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.emr.id}",
      "arn:aws:s3:::${aws_s3_bucket.emr.id}/*"
    ]
  }

  statement {
    sid       = "CreateServiceLinkedRoleAllow"
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["arn:aws:iam::${var.account}:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot*"]
    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["spot.amazonaws.com"]
    }
  }
}

# EMR Cluster EC2 Role
resource "aws_iam_role" "emr_ec2_role" {
  name               = "AE_EMR_EC2_Role"
  assume_role_policy = data.aws_iam_policy_document.emr_ec2_role_assume_role.json
  tags               = var.common_tags
}

data "aws_iam_policy_document" "emr_ec2_role_assume_role" {
  statement {
    sid     = "AllowEmrEC2ToAssumeRole"
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
  statement {
    sid    = "AllowEmrEC2toPutCloudwatchMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
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
    sid    = "AllowEmrEC2ReadGlue"
    effect = "Allow"
    actions = [
      "glue:Get*",
      "glue:List*",
      "glue:BatchGet*"
    ]
    resources = [
      "arn:aws:glue:${var.region}:${var.account}:catalog",
      "arn:aws:glue:${var.region}:${var.account}:database/${var.dataset_glue_db}",
      "arn:aws:glue:${var.region}:${var.account}:database/${var.dataset_glue_db}_staging",
      "arn:aws:glue:${var.region}:${var.account}:table/${var.dataset_glue_db}/*",
      "arn:aws:glue:${var.region}:${var.account}:table/${var.dataset_glue_db}_staging/*"
    ]
  }

  statement {
    sid    = "AllowEC2GetDefaultGlueDatabases"
    effect = "Allow"
    actions = [
      "glue:GetDatabase"
    ]
    resources = [
      "arn:aws:glue:${var.region}:${var.account}:database/default",
      "arn:aws:glue:${var.region}:${var.account}:database/global_temp"
    ]
  }

  statement {
    sid    = "AllowEmrEc2AccessMetadataDynamodb"
    effect = "Allow"
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteTable",
      "dynamodb:UpdateTable"
    ]
    resources = [
      "arn:aws:dynamodb:${var.region}:${var.account}:table/EmrFSMetadata"
    ]
  }

  statement {
    sid    = "AllowEmrEc2AccessEMRFSInconsitenecySQS"
    effect = "Allow"
    actions = [
      "sqs:GetQueueUrl",
      "sqs:DeleteMessageBatch",
      "sqs:ReceiveMessage",
      "sqs:DeleteQueue",
      "sqs:SendMessage",
      "sqs:CreateQueue"
    ]
    resources = [
      "arn:aws:sqs:${var.region}:${var.account}:EMRFS-Inconsistency-*"
    ]
  }

  statement {
    sid    = "AllowEmrEc2ACMExport"
    effect = "Allow"
    actions = [
      "acm:ExportCertificate",
    ]
    resources = [
      aws_acm_certificate.emr.arn
    ]
  }

  statement {
    sid    = "AllowEmrEc2GetPrivateCAGetCertificate"
    effect = "Allow"
    actions = [
      "acm-pca:GetCertficate"
    ]
    resources = [
      var.cert_authority_arn
    ]
  }

  statement {
    sid    = "AllowEmrEc2KMSAccessSpecificKeys"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [
      aws_kms_key.emr_ebs.arn,
      aws_kms_key.emr_s3.arn,
      var.artefact_bucket.kms_arn
    ]
  }

  statement {
    sid    = "AllowEmrEc2S3ReadSpecificBuckets"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:CreateBucket",
      "s3:DeleteObject",
      "s3:GetBucketVersioning",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:ListMultipartUploadParts",
      "s3:PutBucketVersioning",
      "s3:PutObject",
      "s3:PutObjectTagging"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.emr.id}",
      "arn:aws:s3:::${aws_s3_bucket.emr.id}/*",
      "arn:aws:s3:::eu-west-2.elasticmapreduce",
      "arn:aws:s3:::eu-west-2.elasticmapreduce/*",
      "arn:aws:s3:::${var.env_certificate_bucket}",
      "arn:aws:s3:::${var.env_certificate_bucket}/*",
      "arn:aws:s3:::${var.mgmt_certificate_bucket}",
      "arn:aws:s3:::${var.mgmt_certificate_bucket}/*",
      "arn:aws:s3:::${var.log_bucket}",
      "arn:aws:s3:::${var.log_bucket}/*",
      "arn:aws:s3:::${var.artefact_bucket.id}",
      "arn:aws:s3:::${var.artefact_bucket.id}/*"
    ]
  }

  statement {
    sid    = "AllowEmrEc2S3PutLogAndEMRBucket"
    effect = "Allow"
    actions = [
      "s3:PutBucketVersioning",
      "s3:PutObject",
      "s3:PutObjectTagging"
    ]
    resources = [
      "arn:aws:s3:::${var.log_bucket}",
      "arn:aws:s3:::${var.log_bucket}/*",
      "arn:aws:s3:::eu-west-2.elasticmapreduce",
      "arn:aws:s3:::eu-west-2.elasticmapreduce/*",
    ]
  }

  statement {
    sid    = "AllowEmrEc2AssumeReadOnlyCognitoRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [aws_iam_role.cogntio_read_only_role.arn]
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
    sid     = "AllowCrossAccountAssumeRole"
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

# EMR SSM Policy
resource aws_iam_role_policy amazon_ec2_role_for_ssm {
  role   = aws_iam_role.emr_ec2_role.name
  policy = data.aws_iam_policy_document.amazon_ec2_role_for_ssm.json
  name   = "AE_ElasticMapReduceforEC2Role_SSM"
}

data aws_iam_policy_document amazon_ec2_role_for_ssm {
  statement {
    sid    = "AllowSSMActions"
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
    resources = [
      "*" # Restrictions not supported on SSM
    ]
  }

  statement {
    sid    = "AllowSSMMessages"
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
    # Amazon Session Manager Message Gateway Service does not support specifying a resource ARN in the Resource element of an IAM policy statement. To allow access to Amazon Session Manager Message Gateway Service, specify “Resource”: “*” in your policy.
  }

  statement {
    sid    = "AllowEC2Messages"
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
    # EC2 Messages has no service-specific context keys that can be used in the Condition element of policy statements. For the list of the global context keys that are available to all services, see Available Keys for Conditions in the IAM Policy Reference.
  }

  statement {
    sid    = "AllowPutMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = ["*"] # Restrictions not supported for CloudWatch
  }

  statement {
    sid    = "AllowDescribeInstanceStatus"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstanceStatus"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/Application"
      values = [
        "aws-analytical-env"
      ]
    }
  }
}

# EMR Autoscaling Role
resource "aws_iam_role" "emr_autoscaling_role" {
  name               = "AE_EMR_AutoScaling_Role"
  assume_role_policy = data.aws_iam_policy_document.emr_autoscaling_role_assume_role.json
  tags               = var.common_tags
}

data "aws_iam_policy_document" "emr_autoscaling_role_assume_role" {
  statement {
    sid     = "AllowAssumeRole"
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
    sid    = "AllowDescribeCWAlarms"
    effect = "Allow"
    actions = [
      "cloudwatch:DescribeAlarms"
    ]
    resources = ["arn:aws:cloudwatch:${var.region}:${var.account}:alarm:*"]
  }
  statement {
    sid    = "AllowEMRInstanceGroupModify"
    effect = "Allow"
    actions = [
      "elasticmapreduce:ListInstanceGroups",
      "elasticmapreduce:ModifyInstanceGroups"
    ]
    resources = ["arn:aws:elasticmapreduce:${var.region}:${var.account}:cluster:${var.emr_cluster_name}"]
    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/Application"
      values = [
        "aws-analytical-env"
      ]
    }
  }
}
