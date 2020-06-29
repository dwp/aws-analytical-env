output "emr_hostname" {
  value = module.emr.emr_cluster_cname
}

output "emr_sg_id" {
  value = module.emr.emr_security_group_id
}

output "emrfs_iam_roles" {
  value = module.emr.emrfs_iam_roles
}
