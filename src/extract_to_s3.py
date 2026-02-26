import json
import os
import re

import boto3
from botocore.exceptions import ClientError

from .config import S3_BUCKET, S3_PREFIX, logger


def slugify(name):
    return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")


def upload_to_s3(records, s3_key):
    if not S3_BUCKET:
        raise ValueError("S3_BUCKET_NAME environment variable is not set")

    json_content = json.dumps(records, indent=2)
    s3_client = boto3.client("s3")

    logger.info(f"Uploading to s3://{S3_BUCKET}/{s3_key}")
    try:
        s3_client.put_object(
            Bucket=S3_BUCKET,
            Key=s3_key,
            Body=json_content.encode("utf-8"),
            ContentType="application/json",
        )
    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        if error_code == "NoSuchBucket":
            raise ValueError(
                f"Bucket '{S3_BUCKET}' does not exist. "
                f"Run 'terraform apply' first to create it."
            ) from e
        elif error_code in ("AccessDenied", "InvalidAccessKeyId"):
            raise PermissionError(
                f"Access denied to bucket '{S3_BUCKET}'. "
                f"Check IAM permissions for the execution role."
            ) from e
        else:
            raise

    logger.info("Upload successful!")
    return s3_key


def save_locally(records, filepath):
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with open(filepath, "w") as f:
        json.dump(records, f, indent=2)
    logger.info(f"Local copy saved to: {filepath}")
    return filepath
