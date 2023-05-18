variable "assume_role" {
  type    = string
  default = "ci"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "emr_release" {
  default = {
    development = "6.3.0"
    qa          = "6.3.0"
    integration = "6.3.0"
    preprod     = "6.3.0"
    production  = "6.3.0"
  }
}
variable "aws_analytical_env_emr_launcher_zip" {
  type = map(string)

  default = {
    base_path = ""
    version   = ""
  }
}

variable "manage_mysql_user_lambda_zip" {
  type = map(string)

  default = {
    base_path = ""
    version   = ""
  }
}

variable "emr_core_instance_count" {
  default = {
    development = "1"
    qa          = "1"
    integration = "1"
    preprod     = "3"
    production  = "30"
  }
}

variable "uc_lab_core_instance_count" {
  default = {
    development = "1"
    qa          = "1"
    integration = "1"
    preprod     = "3"
    production  = "10"
  }
}
variable "test_core_instance_count" {
  default = {
    development = "1"
    qa          = "1"
    integration = "1"
    preprod     = "1"
    production  = "10"
  }
}

variable "payment_timelines_core_instance_count" {
  default = {
    development = "1"
    qa          = "1"
    integration = "1"
    preprod     = "3"
    production  = "10"
  }
}

variable "emr_instance_type_master" {
  default = {
    development = "m5.2xlarge"
    qa          = "m5.2xlarge"
    integration = "m5.2xlarge"
    preprod     = "m5.8xlarge"
    production  = "m5.12xlarge"
  }
}

variable "emr_instance_type_core_one" {
  default = {
    development = "m5.2xlarge"
    qa          = "m5.2xlarge"
    integration = "m5.2xlarge"
    preprod     = "m5.8xlarge"
    production  = "m5.12xlarge"
  }
}
variable "emr_instance_type_core_two" {
  default = {
    development = "m5a.2xlarge"
    qa          = "m5a.2xlarge"
    integration = "m5a.2xlarge"
    preprod     = "m5a.8xlarge"
    production  = "m5a.12xlarge"
  }
}

variable "emr_instance_type_core_three" {
  default = {
    development = "m5d.2xlarge"
    qa          = "m5d.2xlarge"
    integration = "m5d.2xlarge"
    preprod     = "m5d.8xlarge"
    production  = "m5d.12xlarge"
  }
}

variable "emr_al2_ami_id" {
  description = "ID of AMI to be used for EMR clusters"
}

variable "emr_hive_compaction_threads" {
  default = {
    development = "1"
    qa          = "1"
    integration = "1"
    preprod     = "1"
    production  = "1"
  }
}

variable "emr_hive_tez_sessions_per_queue" {
  default = {
    development = "10"
    qa          = "10"
    integration = "10"
    preprod     = "20"
    production  = "20"
  }
}

variable "emr_hive_max_reducers" {
  default = {
    development = "1099"
    qa          = "1099"
    integration = "1099"
    preprod     = "1099"
    production  = "1099"
  }
}

variable "emr_hive_heapsize" {
  default = {
    development = "4096"
    qa          = "4096"
    integration = "4096"
    preprod     = "8192"
    production  = "24576"
  }
}

variable "emr_hive_use_auth" {
  default = {
    development = true
    qa          = true
    integration = true
    preprod     = true
    production  = true
  }
}

variable "hive_custom_auth_jar_path" {
  type = string
}
