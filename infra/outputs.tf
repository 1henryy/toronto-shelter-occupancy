output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value = aws_s3_bucket.data_lake.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value = aws_s3_bucket.data_lake.arn
}

output "s3_user_name" {
  description = "IAM user name for s3 access"
  value = aws_iam_user.s3_user.name
}

output "s3_user_access_key_id" {
  description = "Access Key ID for the s3 user"
  value = aws_iam_access_key.s3_user_key.id
}

output "s3_user_secret_access_key" {
  description = "Secret Access Key for the s3 user"
  value = aws_iam_access_key.s3_user_key.secret
  sensitive = true
}

output "snowflake_iam_role_arn" {
  description = "ARN of the IAM role for Snowflake S3 access"
  value = aws_iam_role.snowflake_s3.arn
}

output "snowflake_warehouse" {
  description = "Snowflake warehouse name"
  value = snowflake_warehouse.data_wh.name
}

output "snowflake_database" {
  description = "Snowflake database name"
  value = snowflake_database.shelter_db.name
}

output "snowflake_storage_integration" {
  description = "Snowflake storage integration name"
  value = snowflake_storage_integration.snowflake_integration.name
}