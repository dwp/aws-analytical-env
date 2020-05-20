variable common_tags {
  description = "common tags to apply to aws resources"
}

variable domain {
  description = "Domain to use for cognito user pool"
  type        = string
}

variable root_dns_names {
  description = "Root dns names to use for cognito callback URLs"
  type        = list(string)
}
