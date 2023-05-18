variable "assume_role" {
  type    = string
  default = "ci"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}


variable "rbac_lambda_file_path" {
  type        = string
  description = "(Required) local file path to rbac testing lambda zip"
  default     = "rbac_test_lambda_files"
}

variable "metrics_lambda_file_path" {
  type        = string
  description = "(Required) local file path to EMR metric collection lambda zip"
  default     = "metrics_lambda_files"
}

variable "metrics_data_s3_folder" {
  type        = string
  description = "(Required) The folder in s3 where our metrics data is stored"
  default     = "metrics-data"
}

variable "name_prefix" {
  type        = string
  description = "(Optional) Name prefix for resources we create, defaults to repository name"
  default     = "analytical-env"
}

variable "test_proxy_user" {
  type        = string
  description = "The user to use when calling Livy"
  default     = "xxxxx"
}

variable "costcode" {
  type    = string
  default = ""
}

variable "ecs_hardened_ami_id" {
  description = "The AMI ID of the latest/pinned Hardened AMI AL2 Image"
  type        = string
}
