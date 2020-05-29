resource "aws_kms_key" "cognito_audit_kms" {
  description             = "${local.name} - cognito_audit_kms"
  deletion_window_in_days = 7
  is_enabled              = true
  enable_key_rotation     = true
  tags                    = merge(var.common_tags, { Name = "cognito_audit_kms", "ProtectSensitiveData" = "True" })
  policy                  = data.aws_iam_policy_document.cognito_logs_kms_key.json
}

resource "aws_kms_alias" "cognito_audit_kms" {
  target_key_id = aws_kms_key.cognito_audit_kms.key_id
  name          = "alias/cognito_audit_kms"
}
