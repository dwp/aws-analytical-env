data aws_s3_bucket_object template_bucket {
  bucket = data.terraform_remote_state.management.outputs.ses_mailer_bucket.id
  key = "default_email_template_analytical_onbording.html"
}
