variable "name_prefix" {
  type        = string
  description = "(Required) Name prefix for resources created"
}

variable "common_tags" {
  description = "(Required) common tags to apply to aws resources"
  type        = map(string)
}

variable "cognito_user_pool_id" {
  description = "(Required) Cognito user pool id"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "(Required) Cognito user pool arn"
  type        = string
}

variable "dynamodb_table_user_arn" {
  description = "(Required) DynamoDB Table User arn"
  type        = string
}

variable "dynamodb_table_user_name" {
  description = "(Required) DynamoDB Table User name"
  type        = string
}

variable "from_email_address" {
  description = "(Required) From email address"
  type        = string
}

variable "template_bucket" {
  description = "(Required) The bucket that has the templated emails"
  type        = string
}

variable "region_domain" {
  description = "(Required) Region where SES domain is registered"
  type        = string
}
