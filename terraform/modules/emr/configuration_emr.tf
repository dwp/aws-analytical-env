resource "aws_s3_bucket_object" "get_dks_cert_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/get_dks_cert.sh"
  content = data.template_file.get_dks_cert_sh.rendered
}

data "template_file" "get_dks_cert_sh" {
  template = file(format("%s/templates/emr/get_dks_cert.sh", path.module))
  vars = {
    emr_bucket_path    = aws_s3_bucket.emr.id
    acm_cert_arn       = aws_acm_certificate.emr.arn
    private_key_alias  = "development"
    truststore_aliases = var.truststore_aliases
    truststore_certs   = var.truststore_certs
    full_proxy         = local.full_proxy
    full_no_proxy      = join(",", local.no_proxy_hosts)
    dks_endpoint       = var.dks_endpoint
  }
}

resource "aws_s3_bucket_object" "emr_setup_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/setup.sh"
  content = data.template_file.emr_setup_sh.rendered
}

data "template_file" "emr_setup_sh" {
  template = file(format("%s/templates/emr/setup.sh", path.module))
  vars = {
    aws_default_region = data.aws_region.current.name
    full_proxy         = local.full_proxy
    full_no_proxy      = join(",", local.no_proxy_hosts)
    cognito_role_arn   = aws_iam_role.cogntio_read_only_role.arn
    user_pool_id       = var.cognito_user_pool_id
  }
}

resource "aws_s3_bucket_object" "hdfs_setup_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/hdfs_setup.sh"
  content = file(format("%s/templates/emr/hdfs_setup.sh", path.module))
}

resource "aws_s3_bucket_object" "livy_client_conf_sh" {
  bucket  = aws_s3_bucket.emr.id
  key     = "scripts/emr/livy_client_conf.sh"
  content = data.template_file.livy_client_conf_sh.rendered
}

resource "aws_s3_bucket_object" "r_packages_install" {
  bucket = aws_s3_bucket.emr.id
  key    = "scripts/emr/r_packages_install.sh"
  content = templatefile("${path.module}/templates/emr/r_packages_install.sh", {
    emr_bucket_path = aws_s3_bucket.emr.id,
    full_proxy      = local.full_proxy,
    full_no_proxy   = join(",", local.no_proxy_hosts),
    packages        = join(";", concat(local.r_dependencies, local.r_packages))
  })
}

resource "aws_s3_bucket_object" "sparkR_install" {
  bucket = aws_s3_bucket.emr.id
  key    = "scripts/emr/sparkR_install.sh"
  content = templatefile("${path.module}/templates/emr/sparkR_install.sh", {
    emr_bucket_path = aws_s3_bucket.emr.id,
    full_proxy      = local.full_proxy,
    full_no_proxy   = join(",", local.no_proxy_hosts),
  })
}

data "template_file" "livy_client_conf_sh" {
  template = file(format("%s/templates/emr/livy_client_conf.sh", path.module))
  vars = {
    livy_client_http_connection_socket_timeout = "5m"
    livy_client_http_connection_timeout        = "30s"
    livy_rsc_client_connect_timeout            = "120s"
    livy_rsc_client_shutdown_timeout           = "10s"
    livy_rsc_job_cancel_timeout                = "600s"
    livy_rsc_job_cancel_trigger_interval       = "500ms"
    livy_rsc_retained_statements               = "200"
    livy_rsc_server_connect_timeout            = "360s"
  }
}
