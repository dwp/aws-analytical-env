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

variable "uc_lab_core_instance_count" {
  type        = string
  description = "(Optional) Number of core instances for uc lab clusters"
  default     = "1"
}

variable "test_core_instance_count" {
  type        = string
  description = "(Optional) Number of core instances for uc lab clusters"
  default     = "1"
}

variable "payment_timelines_core_instance_count" {
  type        = string
  description = "(Optional) Number of core instances for payment timelines clusters"
  default     = "1"
}

variable "environment" {}

variable "application_tag_value" {
  type        = string
  description = "Name of the business Application."
}

variable "environment_tag_value" {
  type        = string
  description = "Name of the HCS Environment."
}

variable "function_tag_value" {
  type        = string
  description = "Function of the organisation."
}

variable "business_project_tag_value" {
  type        = string
  description = "Business Project code for cost allocation."
}

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

variable "hive_compaction_threads" {
  type        = string
  description = "Number of compaction threads"
  default     = "1"
}

variable "hive_tez_sessions_per_queue" {
  type        = string
  description = "The number of sessions for each queue "
  default     = "10"
}

variable "hive_max_reducers" {
  type        = string
  description = "Max number of reducers "
  default     = "1099"
}

variable "alarm_sns_arn" {
  type        = string
  description = "SNS topic for CW metric alarm"
}

variable "alarm_on_failure" {
  type        = number
  description = "0 or 1 value based on alarms needed per environment"
}

variable "proxy_port" {
  type        = string
  description = "Proxy port"
  default     = "3128"
}

variable "tanium_port_1" {
  description = "tanium port 1"
  type        = string
  default     = "16563"
}

variable "tanium_port_2" {
  description = "tanium port 2"
  type        = string
  default     = "16555"
}

variable "tenable_install" {
  description = "Tenable Installation enabled"
  type        = bool
}

variable "trend_install" {
  description = "Trend Installation enabled"
  type        = bool
}

variable "tanium_install" {
  description = "Tanium Installation enabled"
  type        = bool
}

variable "tanium1" {
  description = "tanium server 1"
  type        = string
}

variable "tanium2" {
  description = "tanium server 2"
  type        = string
}

variable "tanium_env" {
  description = "tanium environment"
  type        = string
}

variable "tanium_log_level" {
  description = "tanium log level"
  type        = string
  default     = "41"
}

variable "tenant" {
  description = "trend tenant"
  type        = string
}

variable "tenant_id" {
  description = "trend tenant id"
  type        = string
}

variable "token" {
  description = "trend token"
  type        = string
}

variable "policy_id" {
  description = "policy_id"
  type        = string
  default     = "69"
}

variable "tanium_prefix" {
  description = "tanium_prefix"
  type        = list(string)
  default     = ["dwp-*-aws-cidrs-*"]
}