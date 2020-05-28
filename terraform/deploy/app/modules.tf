module "emr_ami" {
  source = "../../modules/amis"

  providers = {
    aws = aws.management
  }

  ami_filter_name   = "name"
  ami_filter_values = ["dw-emr-ami-*"]
}


module "emr" {
  source = "../../modules/emr"

  common_tags = local.common_tags

  role_arn = {
    management = "arn:aws:iam::${local.account[local.management_account[local.environment]]}:role/${var.assume_role}"
  }

  log_bucket = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id

  ami_id                     = module.emr_ami.ami_id
  cognito_user_pool_id       = data.terraform_remote_state.cognito.outputs.cognito.user_pool_id
  dks_sg_id                  = data.terraform_remote_state.crypto.outputs.dks_sg_id[local.environment]
  dks_subnet                 = data.terraform_remote_state.crypto.outputs.dks_subnet
  dks_endpoint               = data.terraform_remote_state.crypto.outputs.dks_endpoint[local.environment]
  interface_vpce_sg_id       = data.terraform_remote_state.aws_analytical_environment_infra.outputs.interface_vpce_sg_id
  s3_prefix_list_id          = data.terraform_remote_state.aws_analytical_environment_infra.outputs.s3_prefix_list_id
  dynamodb_prefix_list_id    = data.terraform_remote_state.aws_analytical_environment_infra.outputs.dynamodb_prefix_list_id
  internet_proxy             = data.terraform_remote_state.internet_egress.outputs.internet_proxy
  internet_proxy_cidr_blocks = data.terraform_remote_state.internet_egress.outputs.proxy_subnet.cidr_blocks
  parent_domain_name         = local.parent_domain_name[local.environment]
  root_dns_prefix            = local.root_dns_prefix[local.environment]
  cert_authority_arn         = data.terraform_remote_state.certificate_authority.outputs.root_ca.arn
  vpc                        = data.terraform_remote_state.aws_analytical_environment_infra.outputs.vpc
  env_certificate_bucket     = local.env_certificate_bucket
  emrfs_kms_key_arns         = [data.terraform_remote_state.aws-analytical-dataset-generation.outputs.published_bucket_cmk.arn]
  dataset_s3_paths           = [[data.terraform_remote_state.aws-analytical-dataset-generation.outputs.published_bucket.id, "*"]]
  dataset_s3_tags            = ["collection_tag", "crown"]
  dataset_glue_db            = data.terraform_remote_state.aws-analytical-dataset-generation.outputs.analytical_dataset_generation.job_name

  artefact_bucket = {
    id      = data.terraform_remote_state.management.outputs.artefact_bucket.id
    kms_arn = data.terraform_remote_state.management.outputs.artefact_bucket.cmk_arn
  }
  region                     = var.region
  account                    = local.account[local.management_account[local.environment]]
  environment                = local.environment

  truststore_aliases         = "s3://${data.terraform_remote_state.certificate_authority.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.certificate_authority.outputs.public_cert_bucket.id}/ca_certificates/dataworks/ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/ca.pem"
  truststore_certs           = "dataworks_root_ca,dataworks_mgt_root_ca,env_ca,mgt_ca"
}
