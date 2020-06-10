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
    post_authentication            = string
    pre_token_generation           = string
  })
}

variable s3_log_bucket {
  description = "Bucket to store audit trail in"
  type        = string
}

variable email_template {
  description = "Email template for onboarding of new users"
  type        = string
}

variable ses_domain {
  description = "SES domain identity domain"
  type        = string
}

variable "role_arn" {
  description = "The Role ARN for management account"
  type = object({
    management = string

  })
}
