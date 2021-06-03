resource "aws_kms_key" "jupyter_bucket_master_key" {
  description             = "${var.name_prefix} - JupyterHub Storage Bucket Master Key"
  deletion_window_in_days = 7
  is_enabled              = true
  enable_key_rotation     = true
  tags                    = merge(var.common_tags, { Name = "OSJupyterUserStorage", "ProtectSensitiveData" = "True" })
  policy                  = data.aws_iam_policy_document.jupyter_bucket_kms_key.json
}

resource "aws_kms_alias" "jupyter_bucket_master_key_alias" {
  target_key_id = aws_kms_key.jupyter_bucket_master_key.key_id
  name          = "alias/jupyter_bucket_master_key"
}
