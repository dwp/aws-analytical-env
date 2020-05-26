resource "aws_lambda_function" "lambda_pre_auth" {
  filename         = data.archive_file.lambda_pre_auth_zip.output_path
  function_name    = "${var.name_prefix}-pre-auth"
  role             = aws_iam_role.role_for_lambda_pre_auth.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambda_pre_auth_zip.output_base64sha256
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-pre-auth" })
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.dynamodb_table_user.id
    }
  }
}
