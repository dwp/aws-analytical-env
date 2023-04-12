variable "common_tags" {
  description = "common tags to apply to aws resources"
  type        = map(string)
}

variable "emr_cluster_name" {
  description = "Name of the EMR Cluster"
  default     = "aws-analytical-env"
}

variable "emr_release_label" {
  description = "Version of AWS EMR to deploy with associated applicatoins"
  default     = "emr-5.29.0"
}

variable "emr_applications" {
  description = "List of applications to deploy to EMR Cluster"
  type        = list(string)
  default     = ["Spark", "Livy", "Hive", "TensorFlow"]
}

variable "monitoring_sns_topic_arn" {
  description = "Arn of SNS event to send alerts to Slack"
  type        = string
}

variable "azkaban_pushgateway_hostname" {
  description = "Azkaban pushgateway host"
  type        = string
}

variable "logging_bucket" {
  type        = string
  description = "(Required) The bucket ID for access logging"
}

variable "name_prefix" {
  type        = string
  description = "(Required) Name prefix for resources created"
}

variable "termination_protection" {
  description = "Default setting for Termination Protection"
  type        = bool
  default     = false
}

variable "keep_flow_alive" {
  description = "Indicates whether to keep job flow alive when no active steps"
  type        = bool
  default     = true
}

variable "parent_domain_name" {
  description = "Domain name of Route53 zone to create records in"
}

variable "root_dns_name" {
  description = "Root DNS name"
}

variable "interface_vpce_sg_id" {
  description = "VPC Interface Endpoints security group"
}

variable "dynamodb_prefix_list_id" {
  description = "VPC Prefix list ID for DynamoDB"
}

variable "s3_prefix_list_id" {
  description = "VPC Prefix list ID for S3"
}

variable "vpc" {
  description = "VPC information"
}

variable "role_arn" {
  description = "Role arns for in module providers"
}

variable "internet_proxy_sg_id" {
  description = "Internet proxy SG ID"
}

variable "internet_proxy_dns_name" {
  description = "Internet proxy DNS name"
}

variable "dks_subnet" {
  description = "CIDR ranges of DKS subnets"
}

variable "dks_sg_id" {
  description = "Security Group ID of DKS"
}

variable "dks_endpoint" {
  description = "Endpoint of the DKS service"
}

variable "cert_authority_arn" {
  description = "ARN of the private certificate authority"
}

variable "ami_id" {
  description = "ID of AMI to be used for EMR clusters"
}

variable "env_certificate_bucket" {
  description = "Bucket that contains environment public certificates"
}

variable "mgmt_certificate_bucket" {
  description = "Bucket that contains management environment public certificates"
}

variable "cognito_user_pool_id" {}

variable "dataset_glue_db" {
  description = "Glue database where data generation metadata is stored"
}

variable "log_bucket" {
  description = "(Required) The EMR Log bucket"
  type        = string
}

variable "artefact_bucket" {
  description = "(Required) S3 artefacts bucket"
  type = object({
    id      = string
    kms_arn = string
  })
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "account" {
  description = "AWS account number"
  type        = string
}

variable "environment" {
  description = "Current environment"
  type        = string
}

variable "truststore_aliases" {
  description = "Truststore aliases"
  type        = string
}

variable "truststore_certs" {
  description = "Truststore Certificates"
  type        = string
}

variable "security_configuration_groups" {
  description = "Cognito groups to allow access to S3 data"
  type        = map(list(string))
}

variable "security_configuration_user_roles" {
  description = "Cognito groups to allow access to S3 data"
  type        = map(string)
  default     = {}
}

variable "hive_metastore_username" {
  description = "Username to use when connecting to hive metastore"
  type        = string
}

variable "hive_metastore_password" {
  description = "Name of Secrets Manager secret that contains the password for the hive metastore"
  type        = string
}

variable "hive_metastore_endpoint" {
  description = "Endpoint of the hive metastore"
  type        = string
}

variable "hive_metastore_database_name" {
  description = "Database name of the hive metastore"
  type        = string
}

variable "hive_metastore_sg_id" {
  description = "Security group id of the hive metastore"
  type        = string
}

variable "use_mysql_hive_metastore" {
  description = "Whether to use MySQL hive metastore instead of Glue"
  type        = bool
  default     = false
}

variable "config_bucket_arn" {
  description = "Arn for the Config bucket to read code"
  type        = string
}

variable "config_bucket_cmk" {
  description = "CMK for the Config bucket to read code"
  type        = string
}

variable "config_bucket_id" {
  description = "Id for config bucket"
  type        = string
}

variable "dataset_s3" {
  type        = map(string)
  description = "the data set bucket - id (name) and arn included"
}

variable "published_bucket_cmk" {
  description = "(Required) KMS key arn for accessing the published_bucket"
  type        = string
}

variable "compaction_bucket" {
  type        = map(string)
  description = "compaction bucket - id (name) and arn included"
}

variable "compaction_bucket_cmk" {
  description = "(Required) KMS key arn for accessing the compaction_bucket"
  type        = string
}

variable "processed_bucket_arn" {
  description = "the processed bucket arn "
  type        = string
}

variable "processed_bucket_cmk" {
  description = "(Required) KMS key arn for accessing the processed_bucket"
  type        = string
}

variable "processed_bucket_id" {
  description = "the processed bucket name "
  type        = string
}

variable "rbac_version" {
  description = "the rbac version for the current environment "
  type        = number
}

variable "pipeline_metadata_table" {
  description = "the DynamoDb pipeline metadata table name "
  type        = string
}

variable "s3_tagger_job_definition" {
  description = "The Batch Job Definition ARN for the PDM/S3 Data Tagger"
  type        = string
}

variable "s3_tagger_job_definition_name" {
  description = "The Batch Job Definition name for the PDM/S3 Data Tagger"
  type        = string
}

variable "s3_tagger_job_queue" {
  description = "The Batch Job Queue ARN for the PDM/S3 Data Tagger"
  type        = string
}

variable "jupyterhub_bucket" {
  description = "JupyterHub S3 bucket"
  type = object({
    id      = string
    cmk_arn = string
  })
}

variable "sns_monitoring_queue_arn" {
  description = "The ARN for the monitoring SNS queue"
  type        = string
}

variable "hive_compaction_threads" {
  type        = string
  description = "Number of compaction threads"
  default     = "1"
}

variable "hive_tez_sessions_per_queue" {
  type        = string
  description = "The number of sessions for each queue "
  default     = "10"
}

variable "hive_max_reducers" {
  type        = string
  description = "Max number of reducers "
  default     = "1099"
}

variable "hive_use_auth" {
  type        = bool
  description = "Whether to use custom authentication for Hive Server"
  default     = true
}

variable "hive_custom_auth_provider_path" {
  type        = string
  description = "Local file path of the hive custom auth provider jar"
}

variable "hive_heapsize" {
  type        = string
  description = "Hive heapsize"
  default     = "1024"
}

variable "temporary_bucket_cmk" {
  description = "(Required) KMS key arn for accessing the temporary_bucket"
  type        = string
}

variable "temporary_bucket" {
  description = "temporary bucket - id (name) and arn included"
  type        = map(string)
}

variable "proxy_port" {
  type        = string
  description = "Proxy port"
  default     = "3128"
}
