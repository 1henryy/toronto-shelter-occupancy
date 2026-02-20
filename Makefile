include .env

export

#map terraform variables to env variables

TF_VAR_aws_region := $(AWS_DEFAULT_REGION)
TF_VAR_aws_access_key_id := $(AWS_ACCESS_KEY_ID)
TF_VAR_aws_secret_access_key := $(AWS_SECRET_ACCESS_KEY)
TF_VAR_snowflake_organization_name := $(SNOWFLAKE_ORGANIZATION_NAME)
TF_VAR_snowflake_account_name := $(SNOWFLAKE_ACCOUNT_NAME)
TF_VAR_snowflake_user := $(SNOWFLAKE_USER)
TF_VAR_snowflake_token := $(SNOWFLAKE_TOKEN)
TF_VAR_s3_bucket_name := $(S3_BUCKET_NAME)
TF_VAR_snowflake_warehouse := $(SNOWFLAKE_WAREHOUSE)
TF_VAR_snowflake_warehouse_size := $(SNOWFLAKE_WAREHOUSE_SIZE)
TF_VAR_snowflake_auto_suspend := $(SNOWFLAKE_AUTO_SUSPEND)
TF_VAR_snowflake_min_cluster_count := $(SNOWFLAKE_MIN_CLUSTER_COUNT)
TF_VAR_snowflake_max_cluster_count := $(SNOWFLAKE_MAX_CLUSTER_COUNT)
TF_VAR_snowflake_database := $(SNOWFLAKE_DATABASE)
TF_VAR_snowflake_storage_integration := $(SNOWFLAKE_STORAGE_INTEGRATION)
TF_VAR_s3_iam_policy_name := $(S3_IAM_POLICY_NAME)
TF_VAR_s3_iam_user_name := $(S3_IAM_USER_NAME)
TF_VAR_snowflake_iam_role_name := $(SNOWFLAKE_IAM_ROLE_NAME)


setup:
	pip install -r requirements.txt

infra-init:
	terraform -chdir=infra init

infra-plan:
	terraform -chdir=infra plan

infra-apply:
	terraform -chdir=infra apply



backfill:
	python extract/main.py --backfill

backfill-local:
	python extract/main.py --backfill --skip-s3

incremental:
	python extract/main.py

incremental-local:
	python extract/main.py --skip-s3
