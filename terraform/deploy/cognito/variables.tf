variable "assume_role" {}

variable "region" {}

variable "custom_auth_file_path" {
  description = "Local location of custom auth lambda"
}

variable "name_prefix" {
  type        = string
  description = "(Optional) Name prefix for resources we create, defaults to repository name"
  default     = "analytical-env-cognito"
}
