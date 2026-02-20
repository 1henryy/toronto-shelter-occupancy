terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.32"
    }
    snowflake = {
      source = "snowflakedb/snowflake"
      version = "~> 2.0"
    }
}

  required_version = "~> 1.14.5"
}
