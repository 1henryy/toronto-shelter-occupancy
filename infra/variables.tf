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

variable "aws_access_key_id" {
  type = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type = string
  sensitive = true
}

variable "s3_iam_policy_name" {
  description = "IAM policy name to access S3 bucket"
  type = string
  default = "s3_access"
}

variable "s3_iam_user_name" {
  description = "IAM user name to access S3 bucket"
  type = string
  default = "s3_user"
}

variable "snowflake_iam_role_name" {
  description = "IAM role name for Snowflake to access S3"
  type = string
  default = "snowflake_s3_access"
}

# ── Snowflake ────────────────────────────────────────────

variable "snowflake_organization_name" {
  type = string
}

variable "snowflake_account_name" {
  type = string
}

variable "snowflake_user" {
  type = string
}

variable "snowflake_token" {
  type = string
  sensitive = true
}

variable "snowflake_warehouse" {
  description = "Name of Snowflake warehouse"
  type = string
  default = "DATA_WH"
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
  default = "SHELTER_DB"
}
