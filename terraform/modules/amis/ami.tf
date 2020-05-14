data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = var.ami_filter_name
    values = var.ami_filter_values
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}
