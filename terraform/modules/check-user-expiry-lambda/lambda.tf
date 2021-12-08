resource "aws_lambda_function" "lambda_check_user_expiry" {
  filename         = data.archive_file.lambda_check_user_expiry_zip.output_path
  function_name    = "${var.name_prefix}-check-user-expiry"
  role             = aws_iam_role.role_for_lambda_check_user_expiry.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambda_check_user_expiry_zip.output_base64sha256
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-check-user-expiry" })
  environment {
    variables = {
      TABLE_NAME            = var.dynamodb_table_user_name,
      BUCKET_NAME           = var.template_bucket,
      COGNITO_USER_POOL_ID  = var.cognito_user_pool_id,
      MAIL_FROM             = var.from_email_address,
      REGION_DOMAIN         = var.region_domain,
      REMINDER_SUBJECT_LINE = "[[ recipient_name ]]. Your access to DataWorks AWS is about to expire"
      EXPIRED_SUBJECT_LINE  = "[[ recipient_name ]]. Your access to DataWorks AWS has expired"
    }
  }
}
