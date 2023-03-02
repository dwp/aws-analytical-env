variable "name" {
  type        = string
  description = "Name of the application."
}

variable "proxy_port" {
  type        = number
  default     = 3128
  description = "Port to run the proxy on."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to deploy to."
}

variable "subnet_ids" {
  type        = list(string)
  description = "IDs of the subnets to deploy to."
}

variable "log_bucket_id" {
  type        = string
  description = "S3 Bucket ID to send logs to."
}

variable "environment" {
  type        = string
  description = "Environment to deploy to."
}

variable "config_bucket" {
  type = object({
    id      = string
    arn     = string
    cmk_arn = string
  })
  description = "S3 Bucket ID to pick up config."
}

variable "s3_prefix_list_id" {
  type        = string
  description = "VPC Prefix list ID for S3."
}

variable "parent_domain_name" {
  type        = string
  description = "The parent domain name."
}

variable "ecr_dkr_endpoint" {
  type        = string
  description = "Endpoint to call out to retrieve Proxy container."
}

variable "ecs_cluster" {
  type        = string
  description = "ECS Cluster to deploy proxy to."
}

variable "managed_envs_account_numbers" {
  type        = set(string)
  description = "Account numbers for VPC endpoint service discovery."
}

variable "interface_vpce_sg_id" {
  type        = string
  description = "The VPCe Security group ID."
}

variable "common_tags" {
  type        = map(string)
  description = "Tags common to all resources."
}

variable "name_prefix" {
  type        = string
  description = "Name of service to be used as prefix for resources."
}
