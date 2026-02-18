import argparse
import json
import os
import re
import sys
from datetime import datetime, timedelta

import boto3
import pandas as pd
import requests
from botocore.exceptions import ClientError

from config import BASE_URL, PACKAGE_ID, BATCH_SIZE, S3_BUCKET, S3_PREFIX, DAILY_RESOURCE_NAME, logger

#return a list of all active datastore resources by querying the Toronto Open Data CKAN API 
def get_all_resource_ids():
    url = f"{BASE_URL}/api/3/action/package_show"
    logger.info(f"Fetching package metadata for: {PACKAGE_ID}")

    try:
        response = requests.get(url, params={"id": PACKAGE_ID}, timeout=30).json()
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        raise ValueError(f"Failed to fetch package metadata: {e}") from e

    package = response["result"]
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

