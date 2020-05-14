resource "aws_kms_key" "emr_ebs" {
  description             = "aws-analytical-env-emr-ebs"
  deletion_window_in_days = 30

  tags = merge({ "Name" = var.emr_cluster_name }, var.common_tags)

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "emr_ebs" {
  name          = "alias/aws-analytical-env/emr-ebs"
  target_key_id = aws_kms_key.emr_ebs.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_key" "emr_s3" {
  description             = "aws-analytical-env-emr-s3"
  deletion_window_in_days = 30

  tags = merge({ "Name" = var.emr_cluster_name }, var.common_tags)

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "emr_s3" {
  name          = "alias/aws-analytical-env/emr-s3"
  target_key_id = aws_kms_key.emr_s3.id

  lifecycle {
    prevent_destroy = true
  }
}
