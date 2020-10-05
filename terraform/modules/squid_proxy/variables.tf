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

variable "prefix_list_ids" {
  type = object({
    s3 = string
  })
}

variable "parent_domain_name" {
  type = string
}

variable "cert_authority_arn" {
  type = string
}

variable "ecr_dkr_endpoint" {
  type = string
}

variable "ecs_cluster_arn" {
  type = string
}

variable "mgmt_account_mapping" {
}

variable "managed_envs_account_numbers" {
  type = list(string)
}

variable "common_tags" {
}
