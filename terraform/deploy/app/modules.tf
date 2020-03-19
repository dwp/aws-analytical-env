
module "waf" {
  source = "../../modules/waf"

  name = local.name

  whitelist_cidr_blocks = local.whitelist_cidr_blocks

  file_upload_rate_limit = 800
  file_upload_max_size   = 20480
}
