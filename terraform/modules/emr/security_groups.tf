resource "aws_security_group" "emr" {
  name                   = "emr-communications"
  description            = "Allow EMR Communications"
  vpc_id                 = var.vpc.aws_vpc.id
  revoke_rules_on_delete = true
  tags                   = merge(var.common_tags, { Name : "${var.name_prefix}-emr-sg" })
}

resource "aws_security_group_rule" "egress_https_to_vpc_endpoints" {
  description              = "egress_https_to_vpc_endpoints"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.emr.id
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = var.interface_vpce_sg_id
}

resource "aws_security_group_rule" "ingress_https_vpc_endpoints_from_emr" {
  description              = "ingress_https_vpc_endpoints_from_emr"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = var.interface_vpce_sg_id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = aws_security_group.emr.id
}

resource "aws_security_group_rule" "egress_internet_proxy" {
  description              = "Allow EMR access to proxy"
  from_port                = 3128
  protocol                 = "tcp"
  security_group_id        = aws_security_group.emr.id
  to_port                  = 3128
  type                     = "egress"
  source_security_group_id = var.internet_proxy_sg_id
}

resource "aws_security_group_rule" "ingress_internet_proxy" {
  description              = "Allow proxy access from EMR"
  type                     = "ingress"
  from_port                = 3128
  to_port                  = 3128
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.emr.id
  security_group_id        = var.internet_proxy_sg_id
}

resource "aws_security_group_rule" "egress_mysql_emr_to_metastore" {
  count = var.use_mysql_hive_metastore == true ? 1 : 0

  description              = "Allow MySQL traffic to Aurora RDS from EMR"
  from_port                = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.emr.id
  source_security_group_id = var.hive_metastore_sg_id
  to_port                  = 3306
  type                     = "egress"
}

resource "aws_security_group_rule" "ingress_mysql_metastore_from_emr" {
  count = var.use_mysql_hive_metastore == true ? 1 : 0


  description              = "Allow MySQL traffic from EMR to Aurora RDS"
  from_port                = 3306
  protocol                 = "tcp"
  security_group_id        = var.hive_metastore_sg_id
  source_security_group_id = aws_security_group.emr.id
  to_port                  = 3306
  type                     = "ingress"
}

resource "aws_security_group_rule" "egress_https_from_emr_to_dks" {
  description       = "egress_https_from_emr_to_dks"
  from_port         = local.dks_port
  protocol          = "tcp"
  security_group_id = aws_security_group.emr.id
  to_port           = local.dks_port
  type              = "egress"
  cidr_blocks       = var.dks_subnet.cidr_blocks
}

resource "aws_security_group_rule" "ingress_https_from_emr_to_dks" {
  provider = aws.management

  description       = "ingress_https_from_emr_to_dks"
  from_port         = local.dks_port
  protocol          = "tcp"
  security_group_id = var.dks_sg_id
  to_port           = local.dks_port
  type              = "ingress"
  cidr_blocks       = toset(var.vpc.aws_subnets_private[*].cidr_block)
}

resource "aws_security_group_rule" "egress_emr_nodes" {
  description              = "Alllow outbound traffic between EMR nodes"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  type                     = "egress"
  security_group_id        = aws_security_group.emr.id
  source_security_group_id = aws_security_group.emr.id
}

resource "aws_security_group_rule" "inbound_emr_nodes" {
  description              = "Alllow inbound traffic between EMR nodes"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  type                     = "ingress"
  security_group_id        = aws_security_group.emr.id
  source_security_group_id = aws_security_group.emr.id
}

resource "aws_security_group_rule" "egress_https_to_s3" {
  description       = "Allow HTTPS to S3 endpoint"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.emr.id
  prefix_list_ids   = [var.s3_prefix_list_id]
  type              = "egress"
}

resource "aws_security_group_rule" "egress_to_dynamodb_pl" {
  description       = "egress_to_dynamodb_pl"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.emr.id
  to_port           = 443
  type              = "egress"
  prefix_list_ids   = [var.dynamodb_prefix_list_id]
}

resource "aws_security_group_rule" "egress_http_to_s3" {
  description       = "Allow HTTP (YUM) to S3 endpoint"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.emr.id
  prefix_list_ids   = [var.s3_prefix_list_id]
  type              = "egress"
}

resource "aws_security_group" "emr_master_private" {
  name                   = "analytical_env_emr_master"
  description            = "Analytical Env EMR Master"
  vpc_id                 = var.vpc.aws_vpc.id
  revoke_rules_on_delete = true
  tags                   = merge(var.common_tags, { Name : "${var.name_prefix}-emr-master-priv-sg" })
}

resource "aws_security_group" "emr_slave_private" {
  name                   = "analytical_env_emr_slave"
  description            = "Analytical Env EMR Slave"
  vpc_id                 = var.vpc.aws_vpc.id
  revoke_rules_on_delete = true
  tags                   = merge(var.common_tags, { Name : "${var.name_prefix}-emr-slave-priv-sg" })
}

resource "aws_security_group" "emr_service_access" {
  name                   = "analytical_env_emr_service_access"
  description            = "Analytical Env EMR Service Access"
  vpc_id                 = var.vpc.aws_vpc.id
  revoke_rules_on_delete = true
  tags                   = merge(var.common_tags, { Name : "${var.name_prefix}-emr-access-sg" })
}
