locals {
  fqdn                            = format("%s.%s.%s.", "emr", var.emr_cluster_name, var.root_dns_name)
  master_instance_type            = "m5.2xlarge"
  core_instance_type              = "m5.2xlarge"
  core_instance_count             = 1
  task_instance_type              = "m5.2xlarge"
  ebs_root_volume_size            = 100
  ebs_config_size                 = 250
  ebs_config_type                 = "gp2"
  ebs_config_volumes_per_instance = 1
  autoscaling_min_capacity        = 1
  autoscaling_max_capacity        = 5
  dks_port                        = 8443
  full_proxy                      = var.internet_proxy["http_address"]
  no_proxy_hosts = concat([
    local.fqdn,
    "jupyterhub",
    "127.0.0.1",
    "localhost",
    "169.254.169.254",
    ".s3.eu-west-2.amazonaws.com",
    ".eu-west-2.compute.internal"
  ], formatlist(".%s", var.no_proxy_list))
}

#S3 Required in no proxy list as it is a gateway endpoint