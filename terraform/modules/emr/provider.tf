provider "aws" {
  alias = "management"

  region  = "eu-west-2"
  version = ">= 2.23.0"

  assume_role {
    role_arn = var.role_arn.management
  }
}
