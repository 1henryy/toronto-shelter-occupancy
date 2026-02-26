import json
import requests

from .config import BASE_URL, PACKAGE_ID, BATCH_SIZE, DAILY_RESOURCE_NAME, logger


#return a list of all active datastore resources by making a GET request to the Toronto Open Data CKAN API
def get_all_resources():
    url = f"{BASE_URL}/api/3/action/package_show"
    logger.info(f"Fetching package metadata for: {PACKAGE_ID}")

    try:
        response = requests.get(url, params={"id": PACKAGE_ID}, timeout=30)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        raise ValueError(f"Failed to fetch package metadata: {e}") from e

    package = response.json()["result"]
    logger.info(f"Dataset: {package['title']}")

    resources = []
    for resource in package["resources"]:
        if resource.get("datastore_active", False):
            rid = resource["id"]
            name = resource.get("name", rid)
            logger.info(f"  Active resource: {name} ({rid})")
            resources.append((rid, name))

    if not resources:
        raise ValueError("No active datastore resources found.")

    return resources


#returns the resource ID that gets refreshed daily
def get_daily_resource():
    resources = get_all_resources()
    for rid, name in resources:
        if name == DAILY_RESOURCE_NAME:
            return rid
    raise ValueError(
        f"Could not find resource named '{DAILY_RESOURCE_NAME}'. "
        f"Available: {[name for _, name in resources]}"
    )


#pull all records from a resource with no date filter with pagination
def extract_all(resource_id):
    url = f"{BASE_URL}/api/3/action/datastore_search"
    all_records = []
    offset = 0

    logger.info("Pulling all records...")

    while True:
        params = {
            "id": resource_id,
            "limit": BATCH_SIZE,
            "offset": offset,
        }

        logger.info(f"Fetching batch at offset {offset}...")

        try:
            response = requests.get(url, params=params, timeout=30)
            response.raise_for_status()
        except requests.exceptions.RequestException as e:
            raise ValueError(f"Failed to fetch data at offset {offset}: {e}") from e

        response = response.json()
        records = response["result"]["records"]
        total = response["result"].get("total", "unknown")
        logger.info(f"  Received {len(records)} records (total: {total})")

        if not records:
            break

        all_records.extend(records)

        if len(records) < BATCH_SIZE:
            break

        offset += BATCH_SIZE

    logger.info(f"Extraction complete: {len(all_records)} total records")
    return all_records


#pull records for a date range using a list filter
def extract_by_date(resource_id, start_date, end_date):
    from datetime import datetime, timedelta

    logger.info(f"Pulling records from date range: {start_date} to {end_date}")

    start = datetime.strptime(start_date, "%Y-%m-%d")
    end = datetime.strptime(end_date, "%Y-%m-%d")
    dates = []
    current = start
    while current <= end:
        dates.append(current.strftime("%Y-%m-%d"))
        current += timedelta(days=1)

    url = f"{BASE_URL}/api/3/action/datastore_search"
    all_records = []
    offset = 0

    while True:
        params = {
            "id": resource_id,
            "limit": BATCH_SIZE,
            "offset": offset,
            "filters": json.dumps({"OCCUPANCY_DATE": dates}),
        }

        logger.info(f"Fetching batch at offset {offset}...")

        try:
            response = requests.get(url, params=params, timeout=30)
            response.raise_for_status()
        except requests.exceptions.RequestException as e:
            raise ValueError(f"Failed to fetch data at offset {offset}: {e}") from e

        response = response.json()
        records = response["result"]["records"]
        total = response["result"].get("total", "unknown")
        logger.info(f"  Received {len(records)} records (total: {total})")

        if not records:
            break

        all_records.extend(records)

        if len(records) < BATCH_SIZE:
            break

        offset += BATCH_SIZE

    logger.info(f"Extraction complete: {len(all_records)} total records")
    return all_records
