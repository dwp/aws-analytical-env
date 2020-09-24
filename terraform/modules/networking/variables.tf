variable "name" {
  description = "common name"
  type        = string
}

variable "region" {
  description = "Region to deploy resources into"
  type        = string
  default     = "eu-west-2"
}

variable "common_tags" {
  description = "common tags to apply to aws resources"
  type        = map(string)
}

variable "vpc" {
  description = "vpc configuration block"
  type = object({
    id                  = string
    cidr_block          = string
    main_route_table_id = string
  })
}

variable "role_arn" {
  description = "role arns for inclear module providers"
  type        = map(string)
}

variable "crypto_vpc" {
  description = "Info on the Crypto VPC that contians DKS"
  type        = map(string)
}

variable "crypto_vpc_owner_id" {
  description = "AWS Account ID of the crypto VPC owner"
  type        = string
}

variable "dks_subnet" {
  description = "CIDR ranges of DKS subnets"
  type        = map(list(string))
}

variable "dks_route_table" {
  description = "Route table of DKS subnets"
  type        = map(string)
}

