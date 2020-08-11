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

variable "create_metrics_data_lambda_file_path" {
  type        = string
  description = "(Required) local file path to EMR metrics data creating lambda zip"
}

variable log_bucket {
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

variable "s3_path" {
  type        = string
  description = "the path to the folder in which the data will sit"
  default     = "analytical-dataset/metrics-data"
}

variable "db_name" {
  type        = string
  description = "the name of the database for test data"
  default     = "test_analytical_dataset_generation"
}
