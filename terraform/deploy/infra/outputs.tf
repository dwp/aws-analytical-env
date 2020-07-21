output vpc {
  value = module.networking.outputs
}

output alb {
  value = module.alb.lb
}

output alb_sg {
  value = module.alb.lb_sg
}

output alb_fqdn {
  value = module.alb.fqdn
}

output alb_listner {
  value = module.alb.alb_listener
}

output vpc_main {
  value = module.analytical_env_vpc
}

output interface_vpce_sg_id {
  value = module.analytical_env_vpc.interface_vpce_sg_id
}

output s3_prefix_list_id {
  value = module.analytical_env_vpc.prefix_list_ids.s3
}

output dynamodb_prefix_list_id {
  value = module.analytical_env_vpc.prefix_list_ids.dynamodb
}
