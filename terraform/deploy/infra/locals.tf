data "aws_secretsmanager_secret_version" "internet_ingress" {
  provider  = aws.ssh_bastion
  secret_id = "/concourse/dataworks/internet-ingress"
}

locals {

  deploy_ithc_infra = {
    development = false
    qa          = false
    integration = false
    preprod     = true
    production  = false
  }

  kali_users = jsondecode(data.aws_secretsmanager_secret_version.internet_ingress.secret_binary)["ssh_bastion_users"]
}
