output "output" {
  value = {
    users              = jsondecode(data.external.user_roles.result.users)
    num_configs_needed = data.external.user_roles.result.num_security_configs
  }
}
