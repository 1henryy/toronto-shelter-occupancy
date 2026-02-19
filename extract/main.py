import argparse
import os
import sys
from datetime import datetime, timedelta

import requests
from botocore.exceptions import ClientError

from config import S3_BUCKET, S3_PREFIX, logger
from api_request import get_all_resources, get_daily_resource, extract_all, extract_by_date
from load import slugify, upload_to_s3, save_locally


def run_backfill(skip_s3=False):
    logger.info("Backfill data")

    resources = get_all_resources()
    logger.info(f"Found {len(resources)} active resources")

    for resource_id, resource_name in resources:

        logger.info(f"Extracting: {resource_name}")
        records = extract_all(resource_id)

        if not records:
            logger.warning(f"No data in resource '{resource_name}', skipping...")
            continue

        logger.info(f"Extracted {len(records):,} records")

        slug = slugify(resource_name)
        local_path = os.path.join("data", "raw", "backfill", f"{slug}.json")
        save_locally(records, local_path)

        if not skip_s3:
            s3_key = f"{S3_PREFIX}/backfill/{slug}.json"
            upload_to_s3(records, s3_key)

    logger.info("Backfill complete.")


def run_incremental(start_date, end_date, skip_s3=False):
    logger.info("Incremental data")
    logger.info(f"Date range: {start_date} to {end_date}")

    resource_id = get_daily_resource()
    records = extract_by_date(resource_id, start_date, end_date)

    if not records:
        logger.warning(f"No data found for {start_date} to {end_date}.")
        return None

    logger.info(f"Extracted {len(records):,} records")

    filename = f"{start_date.replace('-', '')}_to_{end_date.replace('-', '')}.json"
    local_path = os.path.join("data", "raw", filename)
    save_locally(records, local_path)

    if skip_s3:
        logger.info("Skipping S3 upload")
        return local_path

    s3_key = f"{S3_PREFIX}/incremental/{filename}"
    upload_to_s3(records, s3_key)
    logger.info(f"Loaded {len(records):,} records into S3://{S3_BUCKET}/{s3_key}")
    return s3_key


def main():
    parser = argparse.ArgumentParser(description="Extract Toronto Shelter Occupancy data.")
    parser.add_argument("--start", help="Start date YYYY-MM-DD (default: 1 week ago)")
    parser.add_argument("--end", help="End date YYYY-MM-DD (default: yesterday)")
    parser.add_argument("--backfill", action="store_true", help="Pull all historical data from every resource")
    parser.add_argument("--skip-s3", action="store_true", help="Save locally only")
    args = parser.parse_args()

    try:
        if args.backfill:
            run_backfill(skip_s3=args.skip_s3)
        else:
            end_date = args.end or (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
            start_date = args.start or (datetime.strptime(end_date, "%Y-%m-%d") - timedelta(days=6)).strftime("%Y-%m-%d")
            run_incremental(start_date=start_date, end_date=end_date, skip_s3=args.skip_s3)
    except (ValueError, PermissionError) as e:
        logger.error(str(e))
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        logger.error(f"API request failed: {e}")
        sys.exit(1)
    except ClientError as e:
        logger.error(f"AWS error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
