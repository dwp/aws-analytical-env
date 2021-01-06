variable "assume_role" {
  type    = string
  default = "ci"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "costcode" {
  type    = string
  default = "PRJ0022507"
}

variable "aws_analytical_env_emr_launcher_zip" {
  type = map(string)

  default = {
    base_path = ""
    version   = ""
  }
}

variable "manage_mysql_user_lambda_zip" {
  type = map(string)

  default = {
    base_path = ""
    version   = ""
  }
}

variable "dataset_s3" {
  type        = map(string)
  description = "the data set bucket - id (name) and arn included"
}

variable "published_bucket_cmk" {
  description = "(Required) KMS key arn for accessing the published_bucket"
  type        = string
}
