# Analytical-Environment cluster config files
resource "aws_s3_bucket_object" "analytical_env_cluster" {
  bucket = var.config_bucket.id
  key    = "emr/aws-analytical-env/cluster.yaml"
  content = templatefile("../../../analytical_env_cluster_config/cluster.yaml.tpl", {
    log_bucket             = var.log_bucket
    ami                    = var.ami
    account                = var.account
    security_configuration = var.analytical_env_security_configuration
    costcode               = var.costcode
    release_version        = var.release_version
    environment            = var.environment
  })
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-emr-launch-cluster" })
}

resource "aws_s3_bucket_object" "analytical_env_instances" {
  bucket = var.config_bucket.id
  key    = "emr/aws-analytical-env/instances.yaml"
  content = templatefile("../../../analytical_env_cluster_config/instances.yaml.tpl", {
    common_security_group  = var.common_security_group
    master_security_group  = var.master_security_group
    slave_security_group   = var.slave_security_group
    service_security_group = var.service_security_group
    subnet_ids             = join(",", var.subnet_ids)
  })
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-emr-launch-instances" })
}

resource "aws_s3_bucket_object" "analytical_env_steps" {
  bucket = var.config_bucket.id
  key    = "emr/aws-analytical-env/steps.yaml"
  content = templatefile("../../../analytical_env_cluster_config/steps.yaml.tpl", {
    config_bucket = var.emr_bucket.id
  })
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-emr-launch-steps" })
}

resource "aws_s3_bucket_object" "analytical_env_configurations" {
  bucket = var.config_bucket.id
  key    = "emr/aws-analytical-env/configurations.yaml"
  content = templatefile("../../../analytical_env_cluster_config/configurations.yaml.tpl", {
    config_bucket                = var.emr_bucket.id
    log_bucket                   = var.log_bucket
    proxy_host                   = var.proxy_host
    full_no_proxy                = var.full_no_proxy
    hive_metastore_endpoint      = var.hive_metastore_endpoint
    hive_metastore_database_name = var.hive_metastore_database_name
    hive_metastore_username      = var.hive_metastore_username
    hive_metastore_secret_id     = var.hive_metastore_secret_id
    environment                  = var.environment
  })
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-emr-launch-config" })
}

# Batch EMR cluster config files
resource "aws_s3_bucket_object" "batch_cluster" {
  bucket = var.config_bucket.id
  key    = "emr/batch-cluster/cluster.yaml"
  content = templatefile("../../../batch_cluster_config/cluster.yaml.tpl", {
    log_bucket             = var.log_bucket
    ami                    = var.ami
    account                = var.account
    security_configuration = var.batch_security_configuration
    costcode               = var.costcode
    release_version        = var.release_version
    environment            = var.environment
  })
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-emr-launch-cluster" })
}

resource "aws_s3_bucket_object" "batch_instances" {
  bucket = var.config_bucket.id
  key    = "emr/batch-cluster/instances.yaml"
  content = templatefile("../../../batch_cluster_config/instances.yaml.tpl", {
    common_security_group    = var.common_security_group
    master_security_group    = var.master_security_group
    slave_security_group     = var.slave_security_group
    service_security_group   = var.service_security_group
    subnet_ids               = join(",", var.subnet_ids)
    core_instance_count      = var.core_instance_count
    instance_type_master     = var.instance_type_master
    instance_type_core_one   = var.instance_type_core_one
    instance_type_core_two   = var.instance_type_core_two
    instance_type_core_three = var.instance_type_core_three

  })
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-emr-launch-instances" })
}

resource "aws_s3_bucket_object" "batch_steps" {
  bucket = var.config_bucket.id
  key    = "emr/batch-cluster/steps.yaml"
  content = templatefile("../../../batch_cluster_config/steps.yaml.tpl", {
    config_bucket = var.emr_bucket.id
  })
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-emr-launch-steps" })
}

resource "aws_s3_bucket_object" "batch_configurations" {
  bucket = var.config_bucket.id
  key    = "emr/batch-cluster/configurations.yaml"
  content = templatefile("../../../batch_cluster_config/configurations.yaml.tpl", {
    config_bucket                = var.emr_bucket.id
    log_bucket                   = var.log_bucket
    proxy_host                   = var.proxy_host
    full_no_proxy                = var.full_no_proxy
    hive_metastore_endpoint      = var.hive_metastore_endpoint
    hive_metastore_database_name = var.hive_metastore_database_name
    hive_metastore_username      = var.hive_metastore_username
    hive_metastore_secret_id     = var.hive_metastore_secret_id
    environment                  = var.environment
  })
  tags = merge(var.common_tags, { Name : "batch-emr-launch-config" })
}
