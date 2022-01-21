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
  description = "(Required) The region to deploy into"
}

variable "account" {
  type        = string
  description = "(Required) The account number of the environment"
}

variable "aws_subnets_private" {
  type        = list(any)
  description = "(Required) The subnet in which the lambda will run"
}

variable "vpc_id" {
  type        = string
  description = "(Required) The VPC ID"
}

variable "emrfs_iam_assume_role_json" {
  type        = string
  description = "(Required) JSON of assume role policy to be used for new emrfs roles"
}

variable "internet_proxy_sg_id" {
  type        = string
  description = "(Required) Internet proxy SG ID"
}

variable "db_client_secret_arn" {
  type        = string
  description = "(Required) The ARN of the client secret for the lambda"
}

variable "db_cluster_arn" {
  type        = string
  description = "(Required) The ARN of the RDS cluster"
}

variable "db_name" {
  type        = string
  description = "(Required) The name of the RDS Database"
}

variable "cognito_user_pool_id" {
  type        = string
  description = "(Required) The Cognito userpool ID"
}

variable "mgmt_account" {
  type        = string
  description = "(Required) The associated management account's ID"
}

variable "management_role_arn" {
  type        = string
  description = "(Required) The associated management account role for mgmt provider"
}

variable "environment" {
  type        = string
  description = "(Required) The local environment that Terraform is running in"
}

variable "s3fs_bucket_id" {
  type        = string
  description = "(Required) The bucket ID for s3fs shared and home dir bucket"
}

variable "s3fs_kms_arn" {
  type        = string
  description = "(Required) The bucket KMS ARN used for encryption of s3fs shared and home dir bucket"
}

variable "monitoring_sns_topic_arn" {
  type        = string
  description = "(Required) Arn of SNS event to send alerts to Slack"
}
