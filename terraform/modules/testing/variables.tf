variable "name_prefix" {
  type        = string
  default     = "analytical-env"
  description = "(Required) Name prefix for resources created"
}

variable "common_tags" {
  type        = map(string)
  description = "(Required) common tags to apply to aws resources"
}

variable "region" {
  type        = string
  description = "(Required) AWS region in which the code is hosted"
  default     = "eu-west-2"
}

variable "environment" {
  type        = string
  description = "the current environment"
}

variable "hcs_environment" {
  type        = string
  description = "the hcs environment"
}

variable "account" {
  type        = string
  description = "(Required) AWS account number"
}

variable "rbac_lambda_file_path" {
  type        = string
  description = "(Required) local file path to rbac testing lambda zip"
}

variable "metrics_lambda_file_path" {
  type        = string
  description = "(Required) local file path to EMR metrics collecting lambda zip"
}

variable "metrics_data_s3_folder" {
  type        = string
  description = "(Required) local file path to EMR metrics data docker folder"
}

variable "log_bucket" {
  description = "Bucket to store audit trail in"
  type        = string
}

variable "vpc" {
  description = "VPC information"
}

variable "emr_host_url" {
  type        = string
  description = "the url of the EMR master node"
}

variable "interface_vpce_sg_id" {
  type        = string
  description = "SG id for VPC endpoints"
}

variable "test_proxy_user" {
  type        = string
  description = "The user to use when calling Livy"
  default     = "e2e_testuser_non_piib0a"
}

variable "metrics_database_name" {
  type        = string
  description = "The name of the metrics database"
  default     = "metrics"
}

variable "small_test_dataset" {
  description = "Table name where our small test data is stored"
  type        = string
  default     = "table1k"
}

variable "large_test_dataset" {
  description = "Table name where our large test data is stored"
  type        = string
  default     = "table5m"
}

variable "dataset_s3" {
  type        = map(string)
  description = "the data set bucket - id (name) and arn included"
}

variable "db_name" {
  type        = string
  description = "the name of the database for test data"
  default     = "metrics"
}

variable "published_bucket_cmk" {
  description = "(Required) KMS key arn for accessing the published_bucket"
  type        = string
}

variable "s3_prefixlist_id" {
  type        = string
  description = "(Required) The PrefixList ID for s3, required for docker pull"
}

variable "subnets" {
  type        = list(string)
  description = "(Required) The subnets required for ec2 instances"
}

variable "mgmt_account" {
  type        = string
  description = "(Required) The local management account"
}

variable "default_ebs_kms_key" {
  type        = string
  description = "The default KMS key used for EBS encryption"
}

variable "metrics_data_batch_image_name" {
  type        = string
  description = "The Container Image name for the Metrics Data Batch job"
}

variable "push_host" {
  type        = string
  description = "The URL for the Pushgateway"
}

variable "push_host_sg" {
  type        = string
  description = "Push Gateway Security Group"
}

variable "emr_host_sg" {
  type        = string
  description = "Security Group for the EMR cluster"
}

variable "proxy_port" {
  description = "proxy port"
  type        = string
  default     = "3128"
}

variable "cw_metrics_data_agent_namespace" {
  description = "cw metrics data agent namespace"
  type        = string
}

variable "cw_agent_metrics_collection_interval" {
  description = "cw metrics collection interval"
  type        = string
  default     = 60
}

variable "cw_agent_cpu_metrics_collection_interval" {
  description = "cw cpu metrics collection interval"
  type        = string
  default     = 60
}

variable "cw_agent_disk_measurement_metrics_collection_interval" {
  description = "cw disk metrics collection interval"
  type        = string
  default     = 60
}

variable "cw_agent_disk_io_metrics_collection_interval" {
  description = "cw disk io metrics collection interval"
  type        = string
  default     = 60
}

variable "cw_agent_mem_metrics_collection_interval" {
  description = "cw mem metrics collection interval"
  type        = string
  default     = 60
}

variable "cw_agent_netstat_metrics_collection_interval" {
  description = "cw netstat metrics collection interval"
  type        = string
  default     = 60
}

variable "asg_autoshutdown" {
  type        = map(string)
  description = "ASG Shutdown Flag"
}

variable "asg_ssmenabled" {
  type        = map(string)
  description = "SSM Enabled Flag"
}