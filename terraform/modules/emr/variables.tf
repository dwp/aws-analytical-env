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
  default     = ["Spark", "Livy"]
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

variable "availability_zone_index" {
  description = "AZ to deploy cluster to"
  default     = 0
  type        = number
}

variable "parent_domain_name" {
  description = "Domain name of Route53 zone to create records in"
}

variable "root_dns_prefix" {
  description = "Domain name prefix of Route53 records"
}

variable "interface_vpce_sg_id" {
  description = "VPC Interface Endpoints security group"
}

variable "vpc" {
  description = "VPC information"
}

variable "role_arn" {
  description = "Role arns for in module providers"
}

variable "internet_proxy" {
  description = "Internet egress proxy ouptuts"
}

variable "internet_proxy_cidr_blocks" {
  description = "Internet egress proxy cidr blocks"
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

variable "emp_dir_path" {
  description = "Local path pointing to the Encryption Materials Provider dir"
}

variable "emrfs_kms_key_arns" {
  type        = list(string)
  default     = []
  description = "KMS keys to be granted access to the emrfs role"
}

variable "dataset_s3_paths" {
  type        = list(tuple([string, string]))
  description = "List of [bucket_name, bucket_path] tuples that emrfs users can access"
}

variable "cognito_user_pool_id" {}
