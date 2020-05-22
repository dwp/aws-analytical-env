provider "aws" {
  alias  = "management-dns"
  region = var.region

  assume_role {
    role_arn = var.role_arn.management-dns
  }
}
