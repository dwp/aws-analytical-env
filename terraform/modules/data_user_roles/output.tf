output "output" {
  value = {
    users = jsondecode(data.external.test.result.users)
    num_configs_needed = data.external.test.result.num_security_configs
  }
}
