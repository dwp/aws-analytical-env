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

variable "engine_version" {
  type        = string
  description = "Version to use for the Aurora MySQL engine. Must be compatible with the serverless engine mode and aurora-mysql5.7 parameter group family"
  default     = "5.7.mysql_aurora.2.07.1"
}

variable "scaling_configuration" {
  type = object({
    auto_pause               = bool
    max_capacity             = number
    min_capacity             = number
    seconds_until_auto_pause = number
    timeout_action           = string
  })
  default = {
    auto_pause               = false
    max_capacity             = 8
    min_capacity             = 1
    seconds_until_auto_pause = 300
    timeout_action           = "RollbackCapacityChange"
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

variable "init_db_sql_path" {
  type        = string
  description = "Path pointing to db initialisation SQL file"
}

variable "config_bucket" {
  type = object({
    id      = string
    cmk_arn = string
  })
}

variable "clients" {
  description = "Map of client names to privileges to create credentials for"
  type        = map(string)
  default     = {}
}

variable "interface_vpce_sg_id" {
  type = string
}

variable "ci_role" {
  type = string
}

