provider "aws" {
  alias   = "management-internet-egress"
  version = ">= 2.23.0"

  assume_role {
    role_arn = var.role_arn.management-internet-egress
  }
}

provider "aws" {
  alias   = "management-crypto"
  version = ">= 2.23.0"

  assume_role {
    role_arn = var.role_arn.management-crypto
  }
}
