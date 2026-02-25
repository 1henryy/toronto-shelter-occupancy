provider "aws" {
  region = var.aws_region
}

provider "snowflake" {
  organization_name = var.snowflake_organization_name
  account_name = var.snowflake_account_name
  user = var.snowflake_user
  authenticator = "SNOWFLAKE_JWT"
  private_key = file(var.snowflake_private_key_path)
  preview_features_enabled = ["snowflake_storage_integration_aws_resource", "snowflake_stage_external_s3_resource", "snowflake_file_format_resource"]
}

# ── S3 ────────────────────────────────────────────────────

#create S3 bucket
resource "aws_s3_bucket" "s3_bucket" { 
  bucket = var.s3_bucket_name

  tags = {
    Project = var.project_name
    ManagedBy = "terraform"
  }
}

#block public access 
resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true 
}

#server side encryption 
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  #AWS-managed encryption
    }
  }
}

# ── Snowflake ─────────────────────────────────────────────

#write IAM policy document for S3 bucket access
data "aws_iam_policy_document" "s3_access" {
  statement {
    sid = "AllowListBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
      ]

    resources = [
      aws_s3_bucket.s3_bucket.arn  
    ]
  }

  statement {
    sid = "AllowReadWriteObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",    
      "s3:PutObject",    
      "s3:DeleteObject",  
    ]

    resources = [
      "${aws_s3_bucket.s3_bucket.arn}/*" 
    ]
  }
}

#create IAM policy with the specifications in the document above
resource "aws_iam_policy" "s3_access" {
  name = var.s3_iam_policy_name
  policy = data.aws_iam_policy_document.s3_access.json
}

#get AWS caller identity for ARN construction
data "aws_caller_identity" "current" {}

#IAM role for Snowflake to assume when reading from S3
resource "aws_iam_role" "snowflake_role" {
  name = var.snowflake_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowSnowflakeAssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = snowflake_storage_integration_aws.snowflake_integration.describe_output[0].iam_user_arn
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = snowflake_storage_integration_aws.snowflake_integration.describe_output[0].external_id
          }
        }
      }
    ]
  })

  tags = {
    Project = var.project_name
    Purpose = "Snowflake access to S3 data lake"
    ManagedBy = "terraform"
  }
}

#attach S3 read policy to Snowflake role
resource "aws_iam_role_policy_attachment" "snowflake_role" {
  role       = aws_iam_role.snowflake_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

#warehouse 
resource "snowflake_warehouse" "data_wh" {
  name = var.snowflake_warehouse
  warehouse_size = var.snowflake_warehouse_size
  auto_suspend = var.snowflake_auto_suspend
  auto_resume = true
  min_cluster_count = var.snowflake_min_cluster_count
  max_cluster_count = var.snowflake_max_cluster_count
}

#database
resource "snowflake_database" "shelter_db" {
  name = var.snowflake_database
}

resource "snowflake_schema" "bronze" {
  database = snowflake_database.shelter_db.name
  name = "BRONZE"
}

resource "snowflake_schema" "silver" {
  database = snowflake_database.shelter_db.name
  name = "SILVER"
}

resource "snowflake_schema" "gold" {
  database = snowflake_database.shelter_db.name
  name = "GOLD"
}

#storage integration to connect Snowflake to S3
resource "snowflake_storage_integration_aws" "snowflake_integration" {
  name = var.snowflake_storage_integration
  enabled                 = true
  storage_provider        = "S3"
  storage_allowed_locations = ["s3://${var.s3_bucket_name}/shelter-occupancy-data/"]
  storage_aws_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.snowflake_iam_role_name}"
}


#file format for JSON data
resource "snowflake_file_format" "json" {
  name             = "JSON_FORMAT"
  database         = snowflake_database.shelter_db.name
  schema           = snowflake_schema.bronze.name
  format_type      = "JSON"
  strip_outer_array = true
}


#external stage pointing to S3 bucket
resource "snowflake_stage_external_s3" "snowflake_stage" {
  name     = var.snowflake_stage
  database = snowflake_database.shelter_db.name
  schema   = snowflake_schema.bronze.name
  url      = "s3://${var.s3_bucket_name}/shelter-occupancy-data/"
  storage_integration = snowflake_storage_integration_aws.snowflake_integration.name

  file_format {
    format_name = "${snowflake_database.shelter_db.name}.${snowflake_schema.bronze.name}.${snowflake_file_format.json.name}"
  }

  depends_on = [
    aws_iam_role.snowflake_role,
    aws_iam_role_policy_attachment.snowflake_role
  ]
}

# ── Lambda ─────────────────────────────────────────────────

#IAM role for Lambda execution
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = var.project_name
    ManagedBy = "terraform"
  }
}

#policy for Lambda1: S3 write and CloudWatch Logs
data "aws_iam_policy_document" "lambda1_policy" {
  statement {
    sid = "AllowS3Write"
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.s3_bucket.arn}/*"
    ]
  }

  statement {
    sid = "AllowCloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]
  }
}

resource "aws_iam_policy" "lambda1_policy" {
  name = var.lambda1_policy_name
  policy = data.aws_iam_policy_document.lambda1_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda1_policy" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda1_policy.arn
}

#CloudWatch log group for lambda1
resource "aws_cloudwatch_log_group" "lambda1_logs" {
  name = "/aws/lambda/${var.lambda1_function_name}"
  retention_in_days = var.lambda1_log_retention_days

  tags = {
    Project = var.project_name
    ManagedBy = "terraform"
  }
}

#create lambda1 function
resource "aws_lambda_function" "lambda1_function" {
  function_name = var.lambda1_function_name
  role = aws_iam_role.lambda_role.arn
  handler = "lambda1.handler"
  runtime = "python3.12"
  memory_size = var.lambda1_memory
  timeout = var.lambda1_timeout

  filename = "${path.module}/../build/lambda1.zip"
  source_code_hash = filebase64sha256("${path.module}/../build/lambda1.zip")

  environment {
    variables = {
      S3_BUCKET_NAME = var.s3_bucket_name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda1_policy,
    aws_cloudwatch_log_group.lambda1_logs,
  ]

  tags = {
    Project = var.project_name
    ManagedBy = "terraform"
  }
}

