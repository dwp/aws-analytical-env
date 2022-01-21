variable "name" {
  description = "common name"
  type        = string
}

variable "whitelist_cidr_blocks" {}

variable "log_bucket" {
  type        = string
  description = "Bucket used for Firehose Logging"
}

variable "name_prefix" {
  type        = string
  description = "Name of service to be used as prefix for resources"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags across all resources"
}
