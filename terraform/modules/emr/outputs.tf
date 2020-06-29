output "emr_cluster_cname" {
  value = aws_route53_record.cluster_cname.fqdn
}

output "emr_security_group_id" {
  value = aws_security_group.emr.id
}

output "emrfs_iam_roles" {
  value = aws_iam_role.emrfs_iam.arn
}
