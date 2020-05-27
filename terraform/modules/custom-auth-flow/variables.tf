variable "name_prefix" {
  type        = string
  description = "(Required) Name prefix for resources created"
}

variable "common_tags" {
  type        = map(string)
  description = "(Required) common tags to apply to aws resources"
}

variable "region" {
  type        = string
  description = "(Required) AWS region in which the code is hosted"
}

variable "account" {
  type        = string
  description = "(Required) AWS account number"
}

variable "cognito_user_pool_arn" {
  type        = string
  description = "(Required) ARN value of the cognito userpool to validate against"
}

variable "custom_auth_file_path" {
  type        = string
  description = "(Required) local file path to custom auth lambda zip"
}
