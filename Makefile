setup:
	pip install -r requirements.txt

infra-init:
	terraform -chdir=terraform init

infra-plan:
	terraform -chdir=terraform plan

infra-apply:
	terraform -chdir=terraform apply

backfill:
	python extract/main.py --backfill

backfill-local:
	python extract/main.py --backfill --skip-s3

incremental:
	python extract/main.py

incremental-local:
	python extract/main.py --skip-s3

dbt-run:
	dbt run --project-dir dbt --profiles-dir dbt

dbt-test:
	dbt test --project-dir dbt --profiles-dir dbt
