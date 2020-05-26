variable "name_prefix" {
  type        = string
  description = "(Required) Name prefix for resources created"
}

variable "common_tags" {
  description = "(Required) common tags to apply to aws resources"
  type        = map(string)
}
