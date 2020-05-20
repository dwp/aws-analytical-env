variable "name" {
  description = "common name"
  type        = string
}

variable "whitelist_cidr_blocks" {}

variable log_bucket {
  type        = string
  description = "Bucket used for Firehose Logging"
}
