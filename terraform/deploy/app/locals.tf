locals {
  azkaban_pushgateway_hostname = "${data.terraform_remote_state.aws_analytical_environment_infra.outputs.private_dns.azkaban_service_discovery.name}.${data.terraform_remote_state.aws_analytical_environment_infra.outputs.private_dns.azkaban_service_discovery_dns.name}"

  emr_launcher_failure_alert = {
    development = 0
    qa          = 0
    integration = 0
    preprod     = 1
    production  = 1
  }

  livy_image_tag = {
    development = "0.0.162"
    qa          = "0.0.162"
    integration = "0.0.162"
    preprod     = "0.0.162"
    production  = "0.0.162"
  }
}
