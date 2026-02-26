variable "project_name" {
  type = string
  default = "toronto-shelter-occupancy"
}

variable "s3_bucket_name" {
  description = "Globally unique name for the S3 data lake bucket"
  type = string
}

# ── AWS ──────────────────────────────────────────────────

variable "aws_region" {
  type = string
}

variable "s3_iam_policy_name" {
  description = "IAM policy name to access S3 bucket"
  type = string
  default = "s3_access"
}


variable "snowflake_iam_role_name" {
  description = "IAM role name for Snowflake to access S3"
  type = string
  default = "snowflake_s3_access"
}

# ── Snowflake ────────────────────────────────────────────

variable "snowflake_private_key_path" {
  description = "Path to RSA private key file for Snowflake auth"
  type = string
  default = "../snowflake_key.p8"
}

variable "snowflake_organization_name" {
  type = string
}

variable "snowflake_account_name" { 
  type = string 
}

variable "snowflake_user" { 
  type = string 
}

variable "snowflake_warehouse" {
  description = "Name of Snowflake warehouse"
  type = string
}

variable "snowflake_warehouse_size" {
  type = string
  default = "XSMALL"
}

variable "snowflake_auto_suspend" {
  type = number
  default = 60
}

variable "snowflake_min_cluster_count" {
  type = number
  default = 1
}

variable "snowflake_max_cluster_count" {
  type = number
  default = 1
}

variable "snowflake_database" {
  description = "Name of Snowflake database"
  type = string
}

variable "snowflake_storage_integration" {
  description = "Name for storage integration"
  type = string
  default = "SNOWFLAKE_INTEGRATION"
}

variable "snowflake_stage" {
  description = "Name for stage"
  type = string
  default = "SNOWFLAKE_STAGE"
}

# ── Lambda ──────────────────────────────────────────────────

variable "lambda_role_name" {
  description = "IAM role name for Lambda execution"
  type = string
  default = "lambda_role"
}

variable "lambda_extract_function_name" {
  description = "Name of lambda_extract function"
  type = string
  default = "lambda_extract"
}

variable "lambda_extract_policy_name" {
  description = "IAM policy name for lambda_extract"
  type = string
  default = "lambda_extract_policy"
}

variable "lambda_extract_memory" {
  description = "Memory (MB) for lambda_extract"
  type = number
  default = 512
}

variable "lambda_extract_timeout" {
  description = "Timeout (seconds) for lambda_extract"
  type = number
  default = 300
}

variable "lambda_extract_log_retention_days" {
  description = "CloudWatch log retention in days"
  type = number
  default = 14
}

