variable "repository_name" {
  type        = string
  description = "(Required) Name for the CodeCommit repository"
}

variable "repository_description" {
  type        = string
  description = "(Required) Description for the CodeCommit repository"
}

variable "common_tags" {
  type        = map(string)
  description = "(Required) common tags to apply to aws resources"
}
