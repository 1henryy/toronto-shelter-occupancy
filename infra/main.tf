provider "aws" {
  region  = var.aws_region
}


#create S3 bucket
resource "aws_s3_bucket" "data_lake" {
  bucket = var.s3_bucket_name

  tags = {
    Project     = var.project_name
    ManagedBy   = "terraform"  
  }
}

#block public access 
resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true  
  block_public_policy     = true  
  ignore_public_acls      = true 
  restrict_public_buckets = true 
}

#server side encryption 
resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  #AWS-managed encryption
    }
  }
}



#write IAM policy document for S3 bucket access
data "aws_iam_policy_document" "s3_access" {
  statement {
    sid    = "AllowListBucket"   
    effect = "Allow"

    actions = [
      "s3:ListBucket"
      ]

    resources = [
      aws_s3_bucket.data_lake.arn  
    ]
  }

  statement {
    sid    = "AllowReadWriteObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",    
      "s3:PutObject",    
      "s3:DeleteObject",  
    ]

    resources = [
      "${aws_s3_bucket.data_lake.arn}/*" 
    ]
  }
}

#create IAM policy with the specifications in the document above
resource "aws_iam_policy" "s3_access" {
  name        = "s3_access"
  policy      = data.aws_iam_policy_document.s3_access.json
}

#create IAM user for S3 bucket access
resource "aws_iam_user" "s3_user" {
  name = "s3_user"

  tags = {
    Project     = var.project_name
    Purpose     = "Programmatic access for the data pipeline"
    ManagedBy   = "terraform"
  }
}

#attach the policy to the user
resource "aws_iam_user_policy_attachment" "s3_access" {
  user       = aws_iam_user.s3_user.name
  policy_arn = aws_iam_policy.s3_access.arn
}

#access keys for the user accessing the s3 bucket
resource "aws_iam_access_key" "s3_user_key" {
  user = aws_iam_user.s3_user.name
}



