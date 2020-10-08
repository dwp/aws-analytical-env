resource "aws_lambda_function" "aws_analytical_env_emr_launcher" {
  filename      = "${var.aws_analytical_env_emr_launcher_zip["base_path"]}/emr-launcher-${var.aws_analytical_env_emr_launcher_zip["version"]}.zip"
  function_name = "aws_analytical_env_emr_launcher"
  role          = aws_iam_role.aws_analytical_env_emr_launcher_lambda_role.arn
  handler       = "emr_launcher.handler"
  runtime       = "python3.7"
  source_code_hash = filebase64sha256(
    format(
      "%s/emr-launcher-%s.zip",
      var.aws_analytical_env_emr_launcher_zip["base_path"],
      var.aws_analytical_env_emr_launcher_zip["version"]
    )
  )
  publish = false
  timeout = 60

  environment {
    variables = {
      EMR_LAUNCHER_CONFIG_S3_BUCKET = var.config_bucket.id
      EMR_LAUNCHER_CONFIG_S3_FOLDER = "emr/aws-analytical-env"
      EMR_LAUNCHER_LOG_LEVEL        = "debug"
    }
  }
  tags = merge(var.common_tags, {Name: "${var.name_prefix}-emr-launch-lambda"})
}
