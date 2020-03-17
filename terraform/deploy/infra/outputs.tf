output vpc {
  value = module.networking.outputs
}

output interface_vpce_sg_id {
  value = module.analytical_env_vpc.interface_vpce_sg_id
}

output s3_prefix_list_id {
  value = module.analytical_env_vpc.s3_prefix_list_id
}
