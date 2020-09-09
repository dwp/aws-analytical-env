variable "name_prefix" {
  type        = string
  description = "(Required) Name prefix for resources we create, defaults to repository name"
}

variable "common_tags" {
  type        = map(string)
  description = "(Required) common tags to apply to aws resources"
}

variable "subnets" {
  type        = list(string)
  description = "(Required) The subnets associated with the task or service."
}

variable "vpc_id" {
  type        = string
  description = "(Required) ID of the VPC"
}

variable "s3_prefixlist_id" {
  type        = string
  description = "(Required) The PrefixList ID for s3, required for docker pull"
}

variable "interface_vpce_sg_id" {
  type        = string
  description = "(Required) The VPCe Security group ID"
}

variable "image_ecr_repository" {
  type        = string
  description = "(Required) The ECR repo containing the Prometheus Pushgateway image"
}

variable "container_name" {
  type        = string
  description = "(Required) Name of the running container"
}

variable "container_port" {
  type        = string
  description = "(Optional) Port on which the container is listening"
  default     = "9091"
}

variable "container_cpu" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-task-defs
  type        = number
  description = "(Optional) The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container_cpu of all containers in a task will need to be lower than the task-level cpu value"
  default     = 1024 # 1 vCPU
}

variable "container_memory" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-task-defs
  type        = number
  description = "(Optional) The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container_memory of all containers in a task will need to be lower than the task memory value"
  default     = 2048 # 8 GB
}

variable "container_memory_reservation" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-task-defs
  type        = number
  description = "(Optional) The amount of memory (in MiB) to reserve for the container. If container needs to exceed this threshold, it can do so up to the set container_memory hard limit"
  default     = 2048 # 2 GB
}

variable "health_check_path" {
  type        = string
  description = "(Optional) Health check path for the Load Balancer"
  default     = "/metrics"
}

variable "management_role_arn" {
  type        = string
  description = "(Required) The role to assume when accessing resources in management"
}

variable "cert_authority_arn" {
  type        = string
  description = "(Required) The ARN of the ACM CA creating our certificate"
}

variable "root_dns_suffix" {
  type        = string
  description = "(Required) Zone to create DNS record in"
}

variable "parent_domain_name" {
  type        = string
  description = "(Required) The parent domain name"
}

variable "logging_bucket" {}
