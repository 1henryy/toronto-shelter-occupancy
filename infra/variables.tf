variable "project_name" {
  type        = string
  default     = "toronto-shelter-occupancy"
}

variable "s3_bucket_name" {
  description = "Globally unique name for the S3 data lake bucket"
  type        = string
}

