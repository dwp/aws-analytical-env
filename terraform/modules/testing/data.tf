data "aws_ami" "hardened" {
  most_recent = true
  owners      = ["self", var.mgmt_account]

  filter {
    name   = "name"
    values = ["dw-ecs-ami-*"]
  }
}

data "aws_ec2_managed_prefix_list" "list" {
  name = "dwp-*-aws-cidrs-*"
}
