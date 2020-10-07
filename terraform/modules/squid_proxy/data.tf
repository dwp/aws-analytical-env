data "aws_secretsmanager_secret_version" "internet_egress" {
  secret_id = "/concourse/dataworks/internet-egress"
}

data "aws_region" "current" {
}

data "aws_availability_zones" "available" {
}

data "aws_caller_identity" "current" {
}
