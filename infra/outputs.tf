output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.data_lake.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.data_lake.arn
}

output "s3_user_name" {
  description = "IAM user name for s3 access"
  value       = aws_iam_user.s3_user.name
}

output "s3_user_access_key_id" {
  description = "Access Key ID for the s3 user"
  value       = aws_iam_access_key.s3_user_key.id
}

output "s3_user_secret_access_key" {
  description = "Secret Access Key for the s3 user"
  value       = aws_iam_access_key.s3_user_key.secret
  sensitive   = true
}

output "snowflake_database" {
  description = "Snowflake database name"
  value       = snowflake_database.shelter.name
}

output "snowflake_bronze_schema" {
  description = "Snowflake bronze schema name"
  value       = snowflake_schema.bronze.name
}

output "snowflake_silver_schema" {
  description = "Snowflake silver schema name"
  value       = snowflake_schema.silver.name
}

output "snowflake_gold_schema" {
  description = "Snowflake gold schema name"
  value       = snowflake_schema.gold.name
}