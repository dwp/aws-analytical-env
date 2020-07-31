data "aws_secretsmanager_secret_version" "internet_ingress" {
  provider  = aws.ssh_bastion
  secret_id = "/concourse/dataworks/internet-ingress"
}

locals {

  env_prefix = {
    development    = "dev."
    qa             = "qa."
    stage          = "stg."
    integration    = "int."
    preprod        = "pre."
    production     = ""
    management-dev = "mgt-dev."
    management     = "mgt."
  }

  dw_domain = "${local.env_prefix[local.environment]}dataworks.dwp.gov.uk"

  deploy_ithc_infra = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = false
  }

  kali_users = jsondecode(data.aws_secretsmanager_secret_version.internet_ingress.secret_binary)["ssh_bastion_users"]
}
