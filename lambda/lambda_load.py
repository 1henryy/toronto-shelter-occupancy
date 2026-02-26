import os
import logging

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend
import snowflake.connector

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def get_snowflake_connection():
    with open("snowflake_key.p8", "rb") as f:
        private_key = serialization.load_pem_private_key(
            f.read(), password=None, backend=default_backend()
        )

    return snowflake.connector.connect(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        warehouse=os.environ["SNOWFLAKE_WAREHOUSE"],
        database="SHELTER_DB",
        schema="BRONZE",
        private_key=private_key,
    )


def handler(event, context):
    mode = event.get("mode", "incremental")
    s3_keys = [r["s3_key"] for r in event.get("results", [])]

    logger.info(f"Lambda invoked — mode: {mode}, files: {len(s3_keys)}")

    conn = get_snowflake_connection()
    cursor = conn.cursor()

    results = []
    total_rows = 0

    for s3_key in s3_keys:
        # Strip the S3 prefix since stage already points to shelter-occupancy-data/
        stage_path = s3_key.replace("shelter-occupancy-data/", "")

        sql = f"""
            COPY INTO RAW_SHELTER_OCCUPANCY
            FROM @SNOWFLAKE_STAGE/{stage_path}
            FILE_FORMAT = JSON_FORMAT
        """

        logger.info(f"Running COPY INTO for: {stage_path}")
        cursor.execute(sql)
        result = cursor.fetchone()

        rows_loaded = result[3] if result else 0

        results.append({"s3_key": s3_key, "rows_loaded": rows_loaded})
        total_rows += rows_loaded

    cursor.close()
    conn.close()

    return {
        "mode": mode,
        "results": results,
        "total_rows": total_rows,
    }
