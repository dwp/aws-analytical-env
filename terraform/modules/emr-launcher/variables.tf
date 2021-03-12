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
variable "hive_metastore_secret_id" {}
variable "hive_metastore_arn" {
  description = "the Hive metastore  arn "
  type        = string
}
variable "subnet_ids" {
  type        = list(string)
  description = "(Required) The ids of the subnets for the cluster"
}

variable "core_instance_count" {
  type        = string
  description = "(Optional) Number of core instances"
  default     = "1"
}
variable "environment" {}

variable "instance_type_master" {
  type        = string
  description = "(Optional) instance type of master"
  default     = "m5.2xlarge"
}

variable "instance_type_core_one" {
  type        = string
  description = "(Optional) instance type1 of core node"
  default     = "m5.2xlarge"
}

variable "instance_type_core_two" {
  type        = string
  description = "(Optional) instance type2 of core node"
  default     = "m5a.2xlarge"
}

variable "instance_type_core_three" {
  type        = string
  description = "(Optional) instance type3 of core node"
  default     = "m5d.2xlarge"
}
