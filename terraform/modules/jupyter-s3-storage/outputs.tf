output "jupyterhub_bucket" {
  description = "The name of the JupyterHub storage bucket"
  value       = aws_s3_bucket.jupyter_storage
}

output "s3fs_bucket_kms_arn" {
  description = "The ARN of the JupyterHub bucket default KMS key"
  value       = aws_kms_key.jupyter_bucket_master_key.arn
}
