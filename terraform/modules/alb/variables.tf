variable "name_prefix" {
  type        = string
  description = "(Required) Name prefix for resources we create, defaults to repository name"
}

variable "cert_authority_arn" {
  type        = string
  description = "(Required) The ARN of the ACM CA creating our certificate"
}

variable "common_tags" {
  type        = map(string)
  description = "(Required) common tags to apply to aws resources"
}

variable "internal_lb" {
  type        = bool
  description = "Whether the load balancer is internal. Valid values are true or false. Default false."
  default     = true
}

variable "alb_subnets" {
  type        = list
  description = "(Required) The subnets associated with the application load balancer."
}

variable "wafregional_web_acl_id" {
  type        = string
  description = "(Required) The WAF that will be protecting this ALB"
}

variable "parent_domain_name" {
  type        = string
  description = "(Required) The parent domain name"
}

variable "root_dns_prefix" {
  type        = string
  description = "(Required) Zone to create DNS record in"
}

variable "vpc_id" {
  type        = string
  description = "(Required) ID of the VPC"
}

variable "whitelist_cidr_blocks" {
  type        = list
  description = "(Required) Rangese we will accept traffic from"
}

variable role_arn {
  type        = map
  description = "(Required) The role used for creating DNS/ACM"
}
