resource "aws_s3_bucket_object" "cluster" {
  bucket = var.config_bucket.id
  key    = "emr/aws-analytical-env/cluster.yaml"
  content = templatefile("../../../cluster_config/cluster.yaml.tpl", {
    log_bucket             = var.log_bucket
    ami                    = var.ami
    account                = var.account
    security_configuration = var.security_configuration
    costcode               = var.costcode
    release_version        = var.release_version
  })
}

resource "aws_s3_bucket_object" "instances" {
  bucket = var.config_bucket.id
  key    = "emr/aws-analytical-env/instances.yaml"
  content = templatefile("../../../cluster_config/instances.yaml.tpl", {
    common_security_group  = var.common_security_group
    master_security_group  = var.master_security_group
    slave_security_group   = var.slave_security_group
    service_security_group = var.service_security_group
  })
}

resource "aws_s3_bucket_object" "steps" {
  bucket = var.config_bucket.id
  key    = "emr/aws-analytical-env/steps.yaml"
  content = templatefile("../../../cluster_config/steps.yaml.tpl", {
    config_bucket = var.config_bucket.id
  })
}

resource "aws_s3_bucket_object" "configurations" {
  bucket = var.config_bucket.id
  key    = "emr/aws-analytical-env/configurations.yaml"
  content = templatefile("../../../cluster_config/configurations.yaml.tpl", {
    config_bucket = var.config_bucket.id
    log_bucket    = var.log_bucket
    proxy_host    = var.proxy_host
    full_no_proxy = var.full_no_proxy
  })
}
