variable "name" {
  type = string
}

variable "proxy_port" {
  default = 3128
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "log_bucket_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "config_bucket" {
  type = object({
    id      = string
    arn     = string
    cmk_arn = string
  })
}

variable "s3_prefix_list_id" {
  type = string
}

variable "parent_domain_name" {
  type = string
}

variable "ecr_dkr_endpoint" {
  type = string
}

variable "ecs_cluster" {
  type = string
}

variable "managed_envs_account_numbers" {
  type = set(string)
}

variable "interface_vpce_sg_id" {
  type = string
}

variable "common_tags" {
  type        = map(string)
  description = "Tags common to all resources"
}

variable "name_prefix" {
  type        = string
  description = "Name of service to be used as prefix for resources"
}
