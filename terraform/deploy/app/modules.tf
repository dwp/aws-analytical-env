module "emr_ami" {
  source = "../../modules/amis"

  providers = {
    aws = aws.management
  }

  ami_filter_name   = "name"
  ami_filter_values = ["dw-emr-ami-*"]
}

// TODO: replace with Analytical Env credentials
data "aws_secretsmanager_secret_version" "hive_metastore_password_secret" {
  provider  = aws
  secret_id = "metadata-store-adg-writer"
}

module "emr" {
  source = "../../modules/emr"

  common_tags = local.common_tags

  role_arn = {
    management = "arn:aws:iam::${local.account[local.management_account[local.environment]]}:role/${var.assume_role}"
  }

  log_bucket = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id

  ami_id                        = module.emr_ami.ami_id
  cognito_user_pool_id          = data.terraform_remote_state.cognito.outputs.cognito.user_pool_id
  dks_sg_id                     = data.terraform_remote_state.crypto.outputs.dks_sg_id[local.environment]
  dks_subnet                    = data.terraform_remote_state.crypto.outputs.dks_subnet
  dks_endpoint                  = data.terraform_remote_state.crypto.outputs.dks_endpoint[local.environment]
  interface_vpce_sg_id          = data.terraform_remote_state.aws_analytical_environment_infra.outputs.interface_vpce_sg_id
  s3_prefix_list_id             = data.terraform_remote_state.aws_analytical_environment_infra.outputs.s3_prefix_list_id
  dynamodb_prefix_list_id       = data.terraform_remote_state.aws_analytical_environment_infra.outputs.dynamodb_prefix_list_id
  internet_proxy                = data.terraform_remote_state.internet_egress.outputs.internet_proxy
  internet_proxy_cidr_blocks    = data.terraform_remote_state.internet_egress.outputs.proxy_subnet.cidr_blocks
  parent_domain_name            = local.parent_domain_name[local.environment]
  root_dns_name                 = local.root_dns_name[local.environment]
  cert_authority_arn            = data.terraform_remote_state.certificate_authority.outputs.root_ca.arn
  vpc                           = data.terraform_remote_state.aws_analytical_environment_infra.outputs.vpc
  env_certificate_bucket        = local.env_certificate_bucket
  mgmt_certificate_bucket       = local.mgmt_certificate_bucket
  emrfs_kms_key_arns            = [data.terraform_remote_state.aws-analytical-dataset-generation.outputs.published_bucket_cmk.arn]
  dataset_s3_paths              = [[data.terraform_remote_state.aws-analytical-dataset-generation.outputs.published_bucket.id, "*"]]
  dataset_s3_tags               = ["collection_tag", "crown"]
  dataset_glue_db               = data.terraform_remote_state.aws-analytical-dataset-generation.outputs.analytical_dataset_generation.job_name
  security_configuration_groups = {
    UC_DataScience_PII = ["AnalyticalDatasetCrownReadOnlyPii"],
    UC_DataScience_Non_PII = ["AnalyticalDatasetCrownReadOnlyPii"]
  }
  monitoring_sns_topic_arn      = data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn


  use_mysql_hive_metastore     = local.use_mysql_hive_metastore[local.environment]
  hive_metastore_endpoint      = data.terraform_remote_state.aws-analytical-dataset-generation.outputs.hive_metastore.rds_cluster.endpoint
  hive_metastore_database_name = data.terraform_remote_state.aws-analytical-dataset-generation.outputs.hive_metastore.rds_cluster.database_name
  hive_metastore_password      = jsondecode(data.aws_secretsmanager_secret_version.hive_metastore_password_secret.secret_string)["password"]
  hive_metastore_username      = "adg-writer" // TODO: replace with Analytical Env credentials
  hive_metastore_sg_id         = data.terraform_remote_state.aws-analytical-dataset-generation.outputs.hive_metastore.security_group.id

  artefact_bucket = {
    id      = data.terraform_remote_state.management_artefacts.outputs.artefact_bucket.id
    kms_arn = data.terraform_remote_state.management_artefacts.outputs.artefact_bucket.cmk_arn
  }
  region      = var.region
  account     = local.account[local.environment]
  environment = local.environment

  truststore_certs   = "s3://${data.terraform_remote_state.certificate_authority.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem"
  truststore_aliases = "dataworks_root_ca,dataworks_mgt_root_ca"

  no_proxy_list = data.terraform_remote_state.aws_analytical_environment_infra.outputs.vpc_main.no_proxy_list
}

module "pushgateway" {
  source = "../../modules/pushgateway"

  name_prefix = "analytical-env-pushgateway"

  container_name       = "prom-pushgateway"
  image_ecr_repository = data.terraform_remote_state.management.outputs.ecr_pushgateway_url

  subnets              = data.terraform_remote_state.aws_analytical_environment_infra.outputs.vpc.aws_subnets_private[*].id
  vpc_id               = data.terraform_remote_state.aws_analytical_environment_infra.outputs.vpc.aws_vpc.id
  interface_vpce_sg_id = data.terraform_remote_state.aws_analytical_environment_infra.outputs.interface_vpce_sg_id
  s3_prefixlist_id     = data.terraform_remote_state.aws_analytical_environment_infra.outputs.s3_prefix_list_id
  logging_bucket       = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id

  management_role_arn = "arn:aws:iam::${local.account[local.management_account[local.environment]]}:role/${var.assume_role}"

  common_tags = local.common_tags

  cert_authority_arn = data.terraform_remote_state.certificate_authority.outputs.root_ca.arn
  parent_domain_name = local.parent_domain_name[local.environment]
  root_dns_suffix    = local.root_dns_name[local.environment]
}

module "codecommit" {
  source = "../../modules/codecommit"

  common_tags = local.common_tags

  repository_name        = "Data_Science-${local.environment}"
  repository_description = "This is the repository for Data Science"

}


module launcher {
  source = "../../modules/emr-launcher"

  emr_bucket                          = module.emr.emr_bucket
  config_bucket                       = data.terraform_remote_state.common.outputs.config_bucket
  config_bucket_cmk                   = data.terraform_remote_state.common.outputs.config_bucket_cmk
  aws_analytical_env_emr_launcher_zip = var.aws_analytical_env_emr_launcher_zip
  ami                                 = module.emr_ami.ami_id
  log_bucket                          = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
  account                             = local.account[local.environment]
  security_configuration              = module.emr.security_configuration
  costcode                            = var.costcode
  release_version                     = "5.29.0"
  common_security_group               = module.emr.common_security_group
  master_security_group               = module.emr.master_security_group
  slave_security_group                = module.emr.slave_security_group
  service_security_group              = module.emr.service_security_group
  proxy_host                          = data.terraform_remote_state.internet_egress.outputs.internet_proxy.dns_name
  full_no_proxy                       = module.emr.full_no_proxy
}

