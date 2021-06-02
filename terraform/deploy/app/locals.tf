locals {
  azkaban_pushgateway_hostname = "${data.terraform_remote_state.aws_analytical_environment_infra.outputs.private_dns.azkaban_service_discovery.name}.${data.terraform_remote_state.aws_analytical_environment_infra.outputs.private_dns.azkaban_service_discovery_dns.name}"
}
