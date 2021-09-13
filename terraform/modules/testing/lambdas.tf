data "archive_file" "rbac_test_lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/${var.rbac_lambda_file_path}"
  output_path = "${path.module}/${var.name_prefix}-${var.rbac_lambda_file_path}.zip"
}

resource "aws_lambda_function" "rbac_test_lambda" {
  filename         = data.archive_file.rbac_test_lambda_package.output_path
  function_name    = "${var.name_prefix}-rbac-test"
  role             = aws_iam_role.role_for_rbac_lambda.arn
  handler          = "rbac_lambda.lambda_handler"
  runtime          = "python3.8"
  timeout          = 300
  source_code_hash = filebase64sha256("${path.module}/${var.name_prefix}-${var.rbac_lambda_file_path}.zip")
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-rbac-test", ProtectSensitiveData = "True" })
  vpc_config {
    security_group_ids = [aws_security_group.rbac_lambda.id]
    subnet_ids         = var.vpc.aws_subnets_private.*.id
  }
  environment {
    variables = {
      HOST_URL = var.emr_host_url
    }
  }
}

data "archive_file" "emr_metrics_lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/${var.metrics_lambda_file_path}"
  output_path = "${path.module}/${var.name_prefix}-${var.metrics_lambda_file_path}.zip"
}

resource "aws_lambda_function" "emr_metrics_lambda" {
  filename         = data.archive_file.emr_metrics_lambda_package.output_path
  function_name    = "${var.name_prefix}-livy-emr-metrics"
  role             = aws_iam_role.role_for_metrics_lambda.arn
  handler          = "metrics_lambda.lambda_handler"
  runtime          = "python3.8"
  timeout          = 900
  source_code_hash = filebase64sha256("${path.module}/${var.name_prefix}-${var.metrics_lambda_file_path}.zip")
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-livy-emr-metrics", ProtectSensitiveData = "True" })
  vpc_config {
    security_group_ids = [aws_security_group.metric_lambda.id]
    subnet_ids         = var.vpc.aws_subnets_private.*.id
  }
  environment {
    variables = {
      HOST_URL  = var.emr_host_url
      PUSH_HOST = var.push_host
    }
  }
}


