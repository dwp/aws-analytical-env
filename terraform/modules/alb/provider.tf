provider "aws" {
  alias  = "management-dns"
  region = "eu-west-2"

  assume_role {
    role_arn = var.role_arn.management-dns
  }
}
