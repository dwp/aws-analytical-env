provider "aws" {
  alias = "management-internet-egress"

  region  = "eu-west-2"
  version = ">= 2.23.0"

  assume_role {
    role_arn = var.role_arn.management-internet-egress
  }
}

provider "aws" {
  alias = "management-crypto"

  region  = "eu-west-2"
  version = ">= 2.23.0"

  assume_role {
    role_arn = var.role_arn.management-crypto
  }
}
