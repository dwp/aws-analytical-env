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

output "emr_common_sg_id" {
  value = module.emr.common_security_group
}

output "livy_proxy" {
  value = module.livy_proxy
}

output "emr_launcher_lambda" {
  value = module.launcher.lambda
}

output "rbac_db" {
  value = module.rbac_db
}

output "emrfs_lambdas" {
  value = module.emrfs_lambda
}

output "s3fs_bucket_kms_arn" {
  value = module.jupyter_s3_storage.s3fs_bucket_kms_arn
}

output "s3fs_bucket" {
  value = {
    id  = module.jupyter_s3_storage.jupyterhub_bucket.id
    arn = module.jupyter_s3_storage.jupyterhub_bucket.arn
  }
}
