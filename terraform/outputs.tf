output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value = aws_s3_bucket.s3_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value = aws_s3_bucket.s3_bucket.arn
}

output "snowflake_iam_role_arn" {
  description = "ARN of the IAM role for Snowflake S3 access"
  value = aws_iam_role.snowflake_role.arn
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
  value = snowflake_storage_integration_aws.snowflake_integration.name
}

output "snowflake_stage" {
  description = "Snowflake S3 stage name"
  value = snowflake_stage_external_s3.snowflake_stage.name
}

output "lambda1_name" {
  description = "Name of the lambda1 function"
  value = aws_lambda_function.lambda1_function.function_name
}

output "lambda1_arn" {
  description = "ARN of the lambda1 function"
  value = aws_lambda_function.lambda1_function.arn
}
