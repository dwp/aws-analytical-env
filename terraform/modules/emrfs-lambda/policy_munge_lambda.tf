resource "aws_lambda_function" "policy_munge_lambda" {
  filename         = data.archive_file.policy_munge_lambda_zip.output_path
  function_name    = "${var.name_prefix}-policy-munge"
  role             = aws_iam_role.policy_munge_lambda_role.arn
  handler          = "lambda_handler.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.policy_munge_lambda_zip.output_base64sha256
  tags             = merge(var.common_tags, { Name = "${var.name_prefix}-policy-munge", "ProtectSensitiveData" = "False" })
  timeout          = 720

  environment {
    variables = {
      DATABASE_CLUSTER_ARN    = var.db_cluster_arn
      DATABASE_NAME           = var.db_name
      SECRET_ARN              = var.db_client_secret_arn
      COMMON_TAGS             = join(",", [for key, val in var.common_tags : "${key}:${val}"])
      ASSUME_ROLE_POLICY_JSON = "${var.emrfs_iam_assume_role_json}"
      FILE_SYSTEM_BUCKET_ARN  = "arn:aws:s3:::${var.s3fs_bucket_id}"
    }
  }

  depends_on = [data.archive_file.policy_munge_lambda_zip]
}
