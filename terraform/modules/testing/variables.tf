variable "name_prefix" {
  type        = string
  default     = "analytical-env"
  description = "(Required) Name prefix for resources created"
}

variable "common_tags" {
  type        = map(string)
  description = "(Required) common tags to apply to aws resources"
}

variable "region" {
  type        = string
  description = "(Required) AWS region in which the code is hosted"
  default     = "eu-west-2"
}

variable "environment" {
  type        = string
  description = "the current environment"
}

variable "account" {
  type        = string
  description = "(Required) AWS account number"
}

variable "rbac_lambda_file_path" {
  type        = string
  description = "(Required) local file path to rbac testing lambda zip"
}

variable log_bucket {
  description = "Bucket to store audit trail in"
  type        = string
}

variable "vpc" {
  description = "VPC information"
}

variable "emr_host_url" {
  type        = string
  description = "the url of the EMR master node"
}
