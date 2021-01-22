resource "aws_iam_role" "aws_analytical_env_emr_launcher_lambda_role" {
  name               = "aws_analytical_env_emr_launcher_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.aws_analytical_env_emr_launcher_assume_policy.json
  tags               = merge(var.common_tags, { Name : "${var.name_prefix}-emr-lambda-role" })
}

data "aws_iam_policy_document" "aws_analytical_env_emr_launcher_assume_policy" {
  statement {
    sid     = "AWSAnalyticalEnvEMRLauncherLambdaAssumeRolePolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "aws_analytical_env_emr_launcher_read_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      format("arn:aws:s3:::%s/*", var.config_bucket.id)
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = [
      var.config_bucket_cmk.arn
    ]
  }
}

data "aws_iam_policy_document" "aws_analytical_env_emr_launcher_runjobflow_policy" {
  statement {
    effect = "Allow"
    actions = [
      "elasticmapreduce:RunJobFlow",
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "aws_analytical_env_emr_launcher_pass_role_document" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/*"
    ]
  }
}

resource "aws_iam_policy" "aws_analytical_env_emr_launcher_read_s3_policy" {
  name        = "AWSAnalyticalEnvReadS3"
  description = "Allow AWS Analytical Env to read from S3 bucket"
  policy      = data.aws_iam_policy_document.aws_analytical_env_emr_launcher_read_s3_policy.json
}

resource "aws_iam_policy" "aws_analytical_env_emr_launcher_runjobflow_policy" {
  name        = "AWSAnalyticalEnvRunJobFlow"
  description = "Allow AWS Analytical Env to run job flow"
  policy      = data.aws_iam_policy_document.aws_analytical_env_emr_launcher_runjobflow_policy.json
}

resource "aws_iam_policy" "aws_analytical_env_emr_launcher_pass_role_policy" {
  name        = "AWSAnalyticalEnvPassRole"
  description = "Allow AWS Analytical Env to pass role"
  policy      = data.aws_iam_policy_document.aws_analytical_env_emr_launcher_pass_role_document.json
}

resource "aws_iam_role_policy_attachment" "aws_analytical_env_emr_launcher_read_s3_attachment" {
  role       = aws_iam_role.aws_analytical_env_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.aws_analytical_env_emr_launcher_read_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_analytical_env_emr_launcher_runjobflow_attachment" {
  role       = aws_iam_role.aws_analytical_env_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.aws_analytical_env_emr_launcher_runjobflow_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_analytical_env_emr_launcher_pass_role_attachment" {
  role       = aws_iam_role.aws_analytical_env_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.aws_analytical_env_emr_launcher_pass_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_analytical_env_emr_launcher_policy_execution" {
  role       = aws_iam_role.aws_analytical_env_emr_launcher_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "aws_analytical_env_emr_launcher_getsecrets" {
  name        = "AWSAnalyticalEnvAGetSecrets"
  description = "Allow AWSAnalyticalEnv Lambda function to get secrets"
  policy      = data.aws_iam_policy_document.aws_analytical_env_emr_launcher_getsecrets.json
}

data "aws_iam_policy_document" "aws_analytical_env_emr_launcher_getsecrets" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      var.hive_metastore_arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "aws_analytical_env_emr_launcher_getsecrets" {
  role       = aws_iam_role.aws_analytical_env_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.aws_analytical_env_emr_launcher_getsecrets.arn
}
