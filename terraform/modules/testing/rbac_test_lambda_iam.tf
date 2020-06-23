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
