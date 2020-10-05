data "template_file" "squid_conf" {
  template = file("templates/squid_conf.tpl")

  vars = {
    environment = var.environment

    cidr_block_analytical_env_dev  = local.host_ranges.development.aws-analytical-env-vpc
    cidr_block_analytical_env_qa   = local.host_ranges.qa.aws-analytical-env-vpc
    cidr_block_analytical_env_int  = local.host_ranges.integration.aws-analytical-env-vpc
    cidr_block_analytical_env_pre  = local.host_ranges.preprod.aws-analytical-env-vpc
    cidr_block_analytical_env_prod = local.host_ranges.production.aws-analytical-env-vpc

  }
}

resource "aws_s3_bucket_object" "squid_conf" {
  bucket     = var.config_bucket.id
  key        = "${local.squid_config_s3_main_prefix}/squid.conf"
  content    = data.template_file.squid_conf.rendered
  kms_key_id = var.config_bucket.cmk_arn
}

data template_file "whitelist" {
  template = file("templates/whitelist.tpl")
}

resource "aws_s3_bucket_object" "ecs_whitelists" {
  bucket     = var.config_bucket.id
  key        = "${local.squid_config_s3_main_prefix}/conf.d/whitelist"
  content    = data.template_file.whitelist[count.index].rendered
  kms_key_id = var.config_bucket.cmk_arn
}
