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

variable auth_lambdas {
  description = "ARNs of auth trigger lambdas"

  type = object({
    create_auth_challenge          = string
    define_auth_challenge          = string
    verify_auth_challenge_response = string
    pre_authentication             = string
  })
}
