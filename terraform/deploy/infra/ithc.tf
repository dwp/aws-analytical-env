data "aws_ami" "kali" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["kali-linux*"]
  }
}

data "template_file" "kali_user_data" {
  template = "./kali_users.cfg"
}

resource "aws_security_group" "kali" {
  count       = local.deploy_ithc_infra[local.environment] ? 1 : 0
  name        = "kali"
  description = "Kali Linux Hosts"
  vpc_id      = module.networking.outputs.aws_vpc.id

  tags = merge(
    local.common_tags,
    { Name = "Kali (ITHC)" }
  )
}

resource "aws_security_group_rule" "kali_allow_ssh_ingress" {
  // cross account SG references require the VPC Peering Connection to be active
  depends_on               = [aws_vpc_peering_connection_accepter.ssh_bastion.0]
  count                    = local.deploy_ithc_infra[local.environment] ? 1 : 0
  description              = "Allow SSH access from bastion hosts"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.internet_ingress.outputs.ssh_bastion.sg.0.id
  security_group_id        = aws_security_group.kali.0.id
}

resource "aws_security_group_rule" "ssh_bastion_allow_ssh_egress" {
  // cross account SG references require the VPC Peering Connection to be active
  depends_on               = [aws_vpc_peering_connection_accepter.ssh_bastion.0]
  count                    = local.deploy_ithc_infra[local.environment] ? 1 : 0
  provider                 = aws.ssh_bastion
  description              = "Allow SSH access to ASI"
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.kali.0.id
  security_group_id        = data.terraform_remote_state.internet_ingress.outputs.ssh_bastion.sg.0.id
}

resource "aws_security_group_rule" "egress_internet_proxy" {
  count                    = local.deploy_ithc_infra[local.environment] ? 1 : 0
  description              = "Allow Internet access via the proxy (for additional ITHC tools)"
  type                     = "egress"
  from_port                = 3128
  to_port                  = 3128
  protocol                 = "tcp"
  source_security_group_id = module.networking.outputs.internet_proxy_vpce.sg_id
  security_group_id        = aws_security_group.kali.0.id
}

resource "aws_security_group_rule" "ingress_internet_proxy" {
  count                    = local.deploy_ithc_infra[local.environment] ? 1 : 0
  description              = "Allow proxy access from Kali"
  type                     = "ingress"
  from_port                = 3128
  to_port                  = 3128
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.kali.0.id
  security_group_id        = module.networking.outputs.internet_proxy_vpce.sg_id
}

resource "aws_security_group_rule" "kali_allow_all_egress" {
  count             = local.deploy_ithc_infra[local.environment] ? 1 : 0
  description       = "Allow all outbound access"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kali.0.id
}

resource "aws_instance" "kali" {
  count                  = local.deploy_ithc_infra[local.environment] ? 1 : 0
  ami                    = data.aws_ami.kali.id
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.kali.0.id]
  subnet_id              = module.networking.outputs.aws_subnets_private.0.id

  user_data = templatefile(
    "${path.module}/kali_users.cloud-cfg.tmpl",
    { users       = local.kali_users,
      http_proxy  = format("http://%s:3128", module.networking.outputs.internet_proxy_vpce.dns_name),
      https_proxy = format("http://%s:3128", module.networking.outputs.internet_proxy_vpce.dns_name),
    }
  )

  tags = merge(
    local.common_tags,
    { Name = "Kali (ITHC)" }
  )
}

resource "aws_vpc_peering_connection" "ssh_bastion" {
  count         = local.deploy_ithc_infra[local.environment] ? 1 : 0
  peer_owner_id = local.account[local.management_account[local.environment]]
  peer_vpc_id   = data.terraform_remote_state.internet_ingress.outputs.vpc.id
  vpc_id        = module.networking.outputs.aws_vpc.id

  tags = merge(
    local.common_tags,
    { Name = "ASI to Internet Ingress (${local.management_account[local.environment]})" }
  )
}

resource "aws_vpc_peering_connection_accepter" "ssh_bastion" {
  count                     = local.deploy_ithc_infra[local.environment] ? 1 : 0
  provider                  = aws.ssh_bastion
  vpc_peering_connection_id = aws_vpc_peering_connection.ssh_bastion.0.id
  auto_accept               = true

  tags = merge(
    local.common_tags,
    { Name = "ASI (${local.environment}) to Internet Ingress" }
  )
}

resource "aws_route" "asi_to_ssh_bastion" {
  count                     = local.deploy_ithc_infra[local.environment] ? length(data.terraform_remote_state.internet_ingress.outputs.ssh_bastion.subnets.*.cidr_block) : 0
  destination_cidr_block    = data.terraform_remote_state.internet_ingress.outputs.ssh_bastion.subnets[count.index].cidr_block
  route_table_id            = module.networking.outputs.aws_route_table_private_ids.0
  vpc_peering_connection_id = aws_vpc_peering_connection.ssh_bastion.0.id
}

resource "aws_route" "ssh_bastion_to_asi" {
  count                     = local.deploy_ithc_infra[local.environment] ? 1 : 0
  provider                  = aws.ssh_bastion
  destination_cidr_block    = module.networking.outputs.aws_vpc.cidr_block
  route_table_id            = data.terraform_remote_state.internet_ingress.outputs.ssh_bastion.route_table.0.id
  vpc_peering_connection_id = aws_vpc_peering_connection.ssh_bastion.0.id
}
