variable "aws_analytical_env_emr_launcher_zip" {
  type = map(string)

  default = {
    base_path = ""
    version   = ""
  }
}

variable "config_bucket" {}
variable "config_bucket_cmk" {}
variable "log_bucket" {}
variable "ami" {}
variable "account" {}
variable "security_configuration" {}
variable "costcode" {}
variable "release_version" {}
variable "common_security_group" {}
variable "master_security_group" {}
variable "slave_security_group" {}
variable "service_security_group" {}
variable "proxy_host" {}
variable "full_no_proxy" {}
