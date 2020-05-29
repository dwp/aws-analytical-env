data archive_file snapshot_cognito_pool {
  type        = "zip"
  source_file = "${path.module}/audit.py"
  output_path = "${path.module}/audit.zip"
}

data "aws_region" "current" {}

resource "aws_lambda_function" "snapshot_cognito_pool" {
  filename         = "${path.module}/audit.zip"
  function_name    = "snapshot_cognito_pool"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "audit.lambda_handler"
  runtime          = "python3.8"
  publish          = false
  source_code_hash = data.archive_file.snapshot_cognito_pool.output_base64sha256
  depends_on       = [aws_cloudwatch_log_group.snapshot_cognito_pool]

  environment {
    variables = {
      REGION     = data.aws_region.current.name
      USERPOOLID = aws_cognito_user_pool.emr.id
      BUCKETNAME = var.s3_log_bucket
    }
  }
  tags = merge(
    var.common_tags,
    {
      "Name" = "snapshot_cognito_pool"
    },
    {
      "ProtectSensitiveData" = "True"
    }
  )
}

resource "aws_cloudwatch_log_group" "snapshot_cognito_pool" {
  name              = "/aws/lambda/snapshot_cognito_pool"
  description       = "Cognito Snapshot Lambda"
  retention_in_days = 180
}
