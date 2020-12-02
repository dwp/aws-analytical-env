resource "aws_lambda_function" "policy_munge_lambda" {
  filename         = data.archive_file.policy_munge_lambda_zip.output_path
  function_name    = var.name_prefix
  role             = aws_iam_role.policy_munge_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.policy_munge_lambda_zip.output_base64sha256
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-policy-munge", "ProtectSensitiveData" = "False" })
  timeout          = 60

  vpc_config {
    subnet_ids         = var.aws_subnets_private
    security_group_ids = [aws_security_group.policy_munge_lambda_sg.id]
  }

  environment {
    DATABASE_ARN            = "********* TO PASS IN *********"
    DATABASE_NAME           = "********* TO PASS IN *********"
    SECRET_ARN              = "********* TO PASS IN *********"
    COMMON_TAGS             = var.common_tags
    ASSUME_ROLE_POLICY_JSON = var.emrfs_iam_assume_role_json
  }
}
