output "emr_cluster_cname" {
  value = aws_route53_record.cluster_cname.fqdn
}

output "emr_security_group_id" {
  value = aws_security_group.emr.id
}

output "emr_bucket" {
  value = aws_s3_bucket.emr
}

output "security_configuration" {
  value = aws_emr_security_configuration.emrfs_em.id
}

output "common_security_group" {
  value = aws_security_group.emr.id
}

output "master_security_group" {
  value = aws_security_group.emr_master_private.id
}

output "slave_security_group" {
  value = aws_security_group.emr_slave_private.id
}

output "service_security_group" {
  value = aws_security_group.emr_service_access.id
}

output "full_no_proxy" {
  value = join("|", local.no_proxy_hosts)
}
