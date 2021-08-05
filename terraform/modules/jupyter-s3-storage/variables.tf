variable "common_tags" {
  type        = map(string)
  description = "(Required) common tags to apply to aws resources"
}

variable "logging_bucket" {
  type        = string
  description = "(Required) The bucket ID for access logging"
}

variable "vpc_id" {
  type        = string
  description = "(Required) The VPC ID from which bucket access is allowed"
}

variable "name_prefix" {
  type        = string
  description = "(Required) Name prefix for resources created"
}

variable "account" {
  type        = string
  description = "(Required) account id for environment"
}
