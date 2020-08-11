data aws_iam_policy_document policy_assume_role_lambda {
  statement {
    sid = "AllowLambdaToAssumeRole"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role_for_rbac_lambda" {
  name               = "rbac_test_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_lambda.json
  tags               = merge(var.common_tags, { Name = "${var.name_prefix}-rbac-test-lambda" })
}

resource "aws_iam_role_policy_attachment" "policy_for_rbac_lambda_basic_execution" {
  role       = aws_iam_role.role_for_rbac_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "policy_for_rbac_lambda_eni_attach" {
  role       = aws_iam_role.role_for_rbac_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
}

resource "aws_iam_role_policy_attachment" "policy_for_rbac_lambda_create_function" {
  role       = aws_iam_role.role_for_rbac_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

resource "aws_iam_role" "role_for_metrics_lambda" {
  name               = "metrics_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_lambda.json
  tags               = merge(var.common_tags, { Name = "${var.name_prefix}-metrics-lambda" })
}

resource "aws_iam_role_policy_attachment" "policy_for_metrics_lambda_basic_execution" {
  role       = aws_iam_role.role_for_metrics_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "policy_for_metrics_lambda_eni_attach" {
  role       = aws_iam_role.role_for_metrics_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
}

resource "aws_iam_role_policy_attachment" "policy_for_metrics_lambda_create_function" {
  role       = aws_iam_role.role_for_metrics_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

resource "aws_iam_policy" "allow_cloudwatch_metrics_push" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "cloudwatch:PutMetricData",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_for_metrics_lambda_cloudwatch_metrics" {
  role       = aws_iam_role.role_for_metrics_lambda.name
  policy_arn = aws_iam_policy.allow_cloudwatch_metrics_push.arn
}

resource "aws_iam_role" "role_for_create_metrics_data_lambda" {
  name               = "create_metrics_data_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_lambda.json
  tags               = merge(var.common_tags, { Name = "${var.name_prefix}-create-metrics-data-lambda" })
}

resource "aws_iam_role_policy_attachment" "policy_for_create_metrics_data_lambda_basic_execution" {
  role       = aws_iam_role.role_for_create_metrics_data_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "policy_for_create_metrics_data_lambda_create_function" {
  role       = aws_iam_role.role_for_create_metrics_data_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

data "aws_iam_policy_document" "create_metrics_data_lambda_policy" {
  statement {
    sid    = "AllowLambdaToUploadToBucket"
    effect = "Allow"
    actions = [
      "s3:ListBuckets",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListObjects",
    ]
    resources = [
      "arn:aws:s3:::${var.dataset_s3.arn}",
      "arn:aws:s3:::${var.dataset_s3.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "policy_for_create_metrics_data_lambda_s3" {
  policy = data.aws_iam_policy_document.create_metrics_data_lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "policy_for_create_metrics_data_lambda_s3" {
  role       = aws_iam_role.role_for_create_metrics_data_lambda.name
  policy_arn = aws_iam_policy.policy_for_create_metrics_data_lambda_s3.arn
}
