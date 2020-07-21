locals {
  fqdn                            = format("%s.%s.%s.", "emr", var.emr_cluster_name, var.root_dns_name)
  master_instance_type            = "m5.2xlarge"
  core_instance_type              = "m5.2xlarge"
  core_instance_count             = 1
  task_instance_type              = "m5.2xlarge"
  ebs_root_volume_size            = 100
  ebs_config_size                 = 250
  ebs_config_type                 = "gp2"
  ebs_config_volumes_per_instance = 1
  autoscaling_min_capacity        = 1
  autoscaling_max_capacity        = 5
  dks_port                        = 8443
  full_proxy                      = var.internet_proxy["http_address"]
  no_proxy_hosts = [
    local.fqdn,
    "jupyterhub",
    "127.0.0.1",
    "localhost",
    "169.254.169.254",
    "*.s3.${data.aws_region.current.name}.amazonaws.com",
    "s3.${data.aws_region.current.name}.amazonaws.com",
    "sns.${data.aws_region.current.name}.amazonaws.com",
    "sqs.${data.aws_region.current.name}.amazonaws.com",
    "${data.aws_region.current.name}.queue.amazonaws.com",
    "glue.${data.aws_region.current.name}.amazonaws.com",
    "sts.${data.aws_region.current.name}.amazonaws.com",
    "*.${data.aws_region.current.name}.compute.internal",
    "dynamodb.${data.aws_region.current.name}.amazonaws.com",
    "*.dkr.ecr.${data.aws_region.current.name}.amazonaws.com",
    "api.ecr.${data.aws_region.current.name}.amazonaws.com",
  ]
  r_packages = [
    "bestglm",
    "bizdays",
    "boot",
    "cluster",
    "colorspace",
    "data.table",
    "deseasonalize",
    "DiagrammeR",
    "DiagrammeRsvg",
    "dplyr",
    "DT",
    "dyn",
    "feather",
    "flexdashboard",
    "forcats",
    "forecast",
    "glmnet",
    "ggplot2",
    "googleVis",
    "Hmisc",
    "htmltools",
    "htmlwidgets",
    "intervals",
    "kableExtra",
    "knitr",
    "lazyeval",
    "leaflet",
    "lubridate",
    "magrittr",
    "manipulate",
    "maps",
    "networkD3",
    "plotly",
    "plyr",
    "RColorBrewer",
    "readr",
    "reshape",
    "reshape2",
    "reticulate",
    "rjson",
    "RJSONIO",
    "rmarkdown",
    "rmongodb",
    "RODBC",
    "scales",
    "shiny",
    "sparklyr",
    "sqldf",
    "stringr",
    "tidyr",
    "timeDate",
    "webshot",
    "xtable",
    "YaleToolkit",
    "zoo"
  ]
}

#S3 Required in no proxy list as it is a gateway endpoint
