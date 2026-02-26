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
