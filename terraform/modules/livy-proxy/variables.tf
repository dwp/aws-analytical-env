variable "name" {
  type    = string
  default = "livy-proxy"
}

variable "ecs_cluster_name" {
  type        = string
  description = "Name of ECS cluster to deploy the service to"
}

variable "desired_count" {
  type        = number
  description = "Number of ECS tasks to deploy"
  default     = 1
}

variable "container_port" {
  default = 8080
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

variable "s3_prefix_list_id" {
  type = string
}

variable "root_dns_suffix" {
  type        = string
  description = "(Required) Zone to create DNS record in"
}

variable "parent_domain_name" {
  type        = string
  description = "(Required) The parent domain name"
}

variable "image_ecr_repository" {
  type        = string
  description = "(Required) The ECR repo containing the Livy Proxy image"
}

variable "interface_vpce_sg_id" {
  type = string
}

variable "livy_sg_id" {
  type        = string
  description = "ID of the Livy security group"
}

variable "management_role_arn" {
  type        = string
  description = "(Required) The role to assume when accessing resources in management"
}

variable "cert_authority_arn" {
  type        = string
  description = "(Required) The ARN of the ACM CA creating our certificate"
}

variable "common_tags" {
  type        = map(string)
  description = "Tags common to all resources"
}

variable "livy_dns_name" {
  type        = string
  description = "DNS name of Livy server"
}

variable "base64_keystore_data" {
  type        = string
  description = "Base64 encoded Cognito JWK keystore data"
}

variable "livy_image_tag" {
  type    = string
  default = "latest"
}
