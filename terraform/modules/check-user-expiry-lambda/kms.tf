resource "aws_kms_key" "key_s3_check_user_expiry_email" {
  description             = "${var.name_prefix}-check-user-expiry-email"
  deletion_window_in_days = 30

  tags = merge({ "Name" = "${var.name_prefix}-check-user-expiry-email" }, var.common_tags)

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "key_s3_check_user_expiry_email" {
  name          = "alias/${var.name_prefix}/check_user_expiry_email"
  target_key_id = aws_kms_key.key_s3_check_user_expiry_email.id

  lifecycle {
    prevent_destroy = true
  }
}
