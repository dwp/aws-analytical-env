variable "assume_role" {
  type    = string
  default = "ci"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}


variable "custom_auth_file_path" {
  description = "Local location of custom auth lambda"
}

variable "name_prefix" {
  type        = string
  description = "(Optional) Name prefix for resources we create, defaults to repository name"
  default     = "analytical-env-cognito"
}
