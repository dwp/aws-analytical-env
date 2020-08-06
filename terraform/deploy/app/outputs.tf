output "emr_hostname" {
  value = module.emr.emr_cluster_cname
}

output "emr_sg_id" {
  value = module.emr.emr_security_group_id
}

output "push_gateway_sg" {
  value = module.pushgateway.push_gateway_sg
}

output "pushgateway" {
  value = module.pushgateway
}
