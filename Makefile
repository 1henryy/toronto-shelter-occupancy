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

dbt-run:
	dbt run --project-dir transform --profiles-dir transform

dbt-test:
	dbt test --project-dir transform --profiles-dir transform
