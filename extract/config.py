import os
import logging
from dotenv import load_dotenv

load_dotenv()

BASE_URL = "https://ckan0.cf.opendata.inter.prod-toronto.ca"
PACKAGE_ID = "21c83b32-d5a8-4106-a54f-010dbe49f6f2"
DAILY_RESOURCE_NAME = "Daily shelter overnight occupancy"
BATCH_SIZE = 10_000

S3_BUCKET = os.getenv("S3_BUCKET_NAME", "")
S3_PREFIX = "shelter-occupancy-data"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-8s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("data_pipeline")
