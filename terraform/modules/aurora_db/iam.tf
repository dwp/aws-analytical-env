data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid    = "LambdaAssumeRolePolicy"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      identifiers = [
        "lambda.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "lambda_manage_mysql_user" {
  name               = "${var.name_prefix}_lambda_manage_mysql_user"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_manage_mysql_user_vpcaccess" {
  role       = aws_iam_role.lambda_manage_mysql_user.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "lambda_manage_mysql_user" {
  statement {
    sid    = "AllowUpdatePassword"
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:TagResource",
      "secretsmanager:ListSecretVersionIds"

    ]
    resources = [
      aws_secretsmanager_secret.master_credentials.arn,
    ]
  }
}

resource "aws_iam_role_policy" "lambda_manage_mysql_user" {
  role   = aws_iam_role.lambda_manage_mysql_user.name
  policy = data.aws_iam_policy_document.lambda_manage_mysql_user.json
}


resource "aws_iam_role" "lambda_initialise_db" {
  name               = "${var.name_prefix}_lambda_initialise_db"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_initialise_db_basic" {
  role       = aws_iam_role.lambda_initialise_db.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_initialise_db" {
  statement {
    sid    = "AllowGetCredentials"
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecretVersionIds"

    ]
    resources = [
      aws_secretsmanager_secret.initialise_db_credentials.arn,
    ]
  }

  statement {
    sid    = "AllowGetInitSql"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "kms:Decrypt"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket_object.init_sql.bucket}/${aws_s3_bucket_object.init_sql.key}",
      var.config_bucket.cmk_arn
    ]
  }
}

resource "aws_iam_role_policy" "lambda_initialise_db" {
  role   = aws_iam_role.lambda_initialise_db.name
  policy = data.aws_iam_policy_document.lambda_initialise_db.json
}
