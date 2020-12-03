variable "name_prefix" {
  type        = string
  description = "Name prefix for resources created by this module"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to aws resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC to deploy resources into"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets to deploy resources into"
}

variable "engine_config" {
  type = object({
    engine         = string
    engine_version = string
    engine_mode    = string
  })
  default = {
    engine                 = "aurora-mysql"
    engine_version         = "5.7.mysql_aurora.2.07.1"
    engine_mode            = "serverless"
    parameter_group_family = "aurora-mysql5.7"
  }
}

variable "backup_config" {
  type = object({
    backup_retention_period      = number
    preferred_backup_window      = string
    preferred_maintenance_window = string
  })

  default = {
    backup_retention_period      = 7
    preferred_backup_window      = "23:00-01:00"
    preferred_maintenance_window = "sun:01:00-sun:06:00"
  }
}

variable "manage_mysql_user_lambda_zip" {
  type = map(string)
  default = {
    base_path = ""
    version   = ""
  }
}
