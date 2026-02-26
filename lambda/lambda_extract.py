from datetime import datetime, timedelta

from src.api_request import get_all_resources, get_daily_resource, extract_all, extract_by_date
from src.extract_to_s3 import upload_to_s3, slugify
from src.config import S3_PREFIX, logger


def handler(event, context):
    mode = event.get("mode", "incremental")
    logger.info(f"Lambda invoked — mode: {mode}")

    if mode == "backfill":
        resources = get_all_resources()
        logger.info(f"Found {len(resources)} active resources")

        results = []
        total_records = 0
        for resource_id, resource_name in resources:
            logger.info(f"Extracting: {resource_name}")
            records = extract_all(resource_id)

            if not records:
                logger.warning(f"No data in resource '{resource_name}', skipping...")
                continue

            logger.info(f"Extracted {len(records):,} records")

            slug = slugify(resource_name)
            s3_key = f"{S3_PREFIX}/backfill/{slug}.json"
            upload_to_s3(records, s3_key)
            results.append({"s3_key": s3_key, "record_count": len(records)})
            total_records += len(records)

        return {
            "mode": "backfill",
            "results": results,
            "total_records": total_records,
        }

    else:
        end_date = event.get("end_date") or (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
        start_date = event.get("start_date") or (datetime.strptime(end_date, "%Y-%m-%d") - timedelta(days=6)).strftime("%Y-%m-%d")

        logger.info(f"Date range: {start_date} to {end_date}")

        resource_id = get_daily_resource()
        records = extract_by_date(resource_id, start_date, end_date)

        if not records:
            logger.warning(f"No data found for {start_date} to {end_date}")
            return {
                "mode": "incremental",
                "results": [],
                "total_records": 0,
            }

        logger.info(f"Extracted {len(records):,} records")

        filename = f"{start_date.replace('-', '')}_to_{end_date.replace('-', '')}.json"
        s3_key = f"{S3_PREFIX}/incremental/{filename}"
        upload_to_s3(records, s3_key)

        return {
            "mode": "incremental",
            "results": [{"s3_key": s3_key, "record_count": len(records)}],
            "total_records": len(records),
        }
