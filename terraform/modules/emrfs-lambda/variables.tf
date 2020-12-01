variable "name_prefix" {
  type        = string
  description = "(Required) Name prefix for resources created"
}

variable "common_tags" {
  type = map(string)
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
  type        = list
  description = "(Required) The subnet in which the lambda will run"
}

variable "vpc_security_group_ids" {
  type        = string
  description = "(Required) The VPC security group IDs"
}

variable "vpc_id" {
  type        = string
  description = "(Required) The VPC ID"
}

variable "master_password" {
  type        = string
  description = "(Required) The master password for the cognito permissions db"
}

variable "master_username" {
  type        = string
  description = "(Required) The master username for the cognito permissions db"
}

variable "db_port" {
  type        = string
  description = "(Required) The port for connection to the db"
}
