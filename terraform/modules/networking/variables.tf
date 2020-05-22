variable "name" {
  description = "common name"
  type        = string
}

variable "region" {
  description = "Region to deploy resources into"
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

variable "internet_transit_gateway" {
  description = "info of the transit gateway"
}

variable "internet_egress_proxy_route_table" {
  description = "management internet egress route table configuration"
}

variable "internet_egress_proxy_subnet" {
  description = "management internet egress proxy subnet configuration"
}

variable "role_arn" {
  description = "role arns for in module providers"
}

variable "crypto_vpc" {
  description = "Info on the Crypto VPC that contians DKS"
}

variable "crypto_vpc_owner_id" {
  description = "AWS Account ID of the crypto VPC owner"
}

variable "dks_subnet" {
  description = "CIDR ranges of DKS subnets"
}

variable "dks_route_table" {
  description = "Route table of DKS subnets"
}

variable "tgw_attachment_internet_egress" {
  description = "Transit Gateway attachment of Internet Egress subnets"
}

variable "tgw_rtb_internet_egress" {
  description = "Transit Gateway route table of Internet Egress subnets"
}

variable "proxy_route_table" {
  description = "Internet Egress route table"
}

variable "proxy_subnet" {
  description = "Internet Egress subnet ranges"
}

variable "analytical_service_vpc" {
  description = "VPC ID Peering to analytical-service vpc"
}
