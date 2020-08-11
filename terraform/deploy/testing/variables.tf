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

variable "create_metrics_data_lambda_file_path" {
  type        = string
  description = "(Required) local file path to EMR metric collection lambda zip"
  default     = "create_metrics_data_lambda_files"
}

variable "name_prefix" {
  type        = string
  description = "(Optional) Name prefix for resources we create, defaults to repository name"
  default     = "analytical-env"
}

variable "costcode" {
  type    = string
  default = ""
}
