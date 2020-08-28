variable "assume_role" {
  type    = string
  default = "ci"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "costcode" {
  type    = string
  default = "PRJ0022507"
}

variable "aws_analytical_env_emr_launcher_zip" {
  type = map(string)

  default = {
    base_path = ""
    version   = ""
  }
}
