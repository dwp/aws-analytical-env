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
