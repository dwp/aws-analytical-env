variable "name" {
  description = "common name"
  type        = string
}

variable "whitelist_cidr_blocks" {}

variable "file_upload_rate_limit" {
  type = number
}

variable "file_upload_max_size" {
  type        = number
  description = "Max file upload size in bytes"
}