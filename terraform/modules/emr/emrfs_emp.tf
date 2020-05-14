resource "aws_s3_bucket_object" "emrfs_emp" {

  bucket = aws_s3_bucket.emr.id
  key    = "emrfs_emp/emp.jar"
  source = "${var.emp_dir_path}/encryption-materials-provider-0.0.6-all.jar"

}
