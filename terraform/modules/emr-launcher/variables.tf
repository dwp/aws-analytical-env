variable "aws_analytical_env_emr_launcher_zip" {
  type = map(string)

  default = {
    base_path = ""
    version   = ""
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Tags common to all resources"
}

variable "name_prefix" {
  type        = string
  description = "Name of service to be used as resource prefix"
}

variable "config_bucket" {}
variable "config_bucket_cmk" {}
variable "log_bucket" {}
variable "emr_bucket" {}
variable "ami" {}
variable "account" {}
variable "analytical_env_security_configuration" {}
variable "batch_security_configuration" {}
variable "costcode" {}
variable "release_version" {}
variable "common_security_group" {}
variable "master_security_group" {}
variable "slave_security_group" {}
variable "service_security_group" {}
variable "proxy_host" {}
variable "full_no_proxy" {}
variable "hive_metastore_endpoint" {}
variable "hive_metastore_database_name" {}
variable "hive_metastore_username" {}
