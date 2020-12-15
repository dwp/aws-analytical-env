provider "aws" {
  alias  = "management"
  region = "eu-west-2"

  assume_role {
    role_arn = var.management_role_arn
  }
}
