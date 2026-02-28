setup:
	pip install -r requirements.txt

infra-init:
	terraform -chdir=terraform init

infra-plan:
	terraform -chdir=terraform plan

infra-apply:
	terraform -chdir=terraform apply

backfill:
	python -m src.main --backfill

backfill-local:
	python -m src.main --backfill --skip-s3

incremental:
	python -m src.main

incremental-local:
	python -m src.main --skip-s3

dbt-run:
	dbt run --project-dir dbt --profiles-dir dbt

dbt-test:
	dbt test --project-dir dbt --profiles-dir dbt

lambda-build-lambda_extract:
	rm -rf build/lambda_extract_pkg build/lambda_extract.zip
	mkdir -p build/lambda_extract_pkg
	pip install requests boto3 -t build/lambda_extract_pkg --quiet
	cp -r src build/lambda_extract_pkg/src
	cp lambda/lambda_extract.py build/lambda_extract_pkg/lambda_extract.py
	cd build/lambda_extract_pkg && zip -r ../lambda_extract.zip . -x "*.pyc" "__pycache__/*"

lambda-deploy-lambda_extract:
	aws lambda update-function-code \
		--function-name lambda_extract \
		--zip-file fileb://build/lambda_extract.zip

lambda-build-lambda_load:
	rm -rf build/lambda_load_pkg build/lambda_load.zip
	mkdir -p build/lambda_load_pkg
	pip install snowflake-connector-python cryptography -t build/lambda_load_pkg --quiet --platform manylinux2014_x86_64 --only-binary=:all:
	cp lambda/lambda_load.py build/lambda_load_pkg/lambda_load.py
	cp snowflake_key.p8 build/lambda_load_pkg/snowflake_key.p8
	cd build/lambda_load_pkg && zip -r ../lambda_load.zip . -x "*.pyc" "__pycache__/*"

lambda-deploy-lambda_load:
	aws lambda update-function-code \
		--function-name lambda_load \
		--zip-file fileb://build/lambda_load.zip
