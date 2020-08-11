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
    security_group_ids = [aws_security_group.sg_for_rbac_lambda.id]
    subnet_ids         = [var.vpc.aws_subnets_private[0].id]
  }
  environment {
    variables = {
      HOST_URL = var.emr_host_url
    }
  }
}

resource "aws_security_group" "sg_for_rbac_lambda" {
  name   = "${var.name_prefix}-rbac-test-lambda-sg"
  vpc_id = var.vpc.aws_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "archive_file" "emr_metrics_lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/${var.metrics_lambda_file_path}"
  output_path = "${path.module}/${var.name_prefix}-${var.metrics_lambda_file_path}.zip"
}

resource "aws_lambda_function" "emr_metrics_lambda" {
  filename         = data.archive_file.emr_metrics_lambda_package.output_path
  function_name    = "${var.name_prefix}-metrics"
  role             = aws_iam_role.role_for_metrics_lambda.arn
  handler          = "metrics_lambda.lambda_handler"
  runtime          = "python3.8"
  timeout          = 300
  source_code_hash = filebase64sha256("${path.module}/${var.name_prefix}-${var.metrics_lambda_file_path}.zip")
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-metrics", ProtectSensitiveData = "True" })
  vpc_config {
    security_group_ids = [aws_security_group.sg_for_metric_lambda.id]
    subnet_ids         = [var.vpc.aws_subnets_private[0].id]
  }
  environment {
    variables = {
      HOST_URL = var.emr_host_url
    }
  }
}

// Security group for metrics lambdas that are placed in VPCs
resource "aws_security_group" "sg_for_metric_lambda" {
  name   = "${var.name_prefix}-metric-lambda-sg"
  vpc_id = var.vpc.aws_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ingress_https_vpc_endpoints_from_metrics_lambda" {
  description              = "ingress_https_vpc_endpoints_from_metrics_lambda"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.interface_vpce_sg_id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = aws_security_group.sg_for_metric_lambda.id
}

