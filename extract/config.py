import os
import logging
from dataclasses import dataclass
from dotenv import load_dotenv

load_dotenv()

#configure Toronto Open Data CKAN API
@dataclass(frozen=True)
class APIConfig:
    base_url: str = "https://ckan0.cf.opendata.inter.prod-toronto.ca"
    package_id: str = "21c83b32-d5a8-4106-a54f-010571a0e10d"
    batch_size: int = 10_000  # Records per API page (CKAN max is ~32,000)
    request_timeout: int = 30  # Seconds before an API call times out
    max_retries: int = 3       # How many times to retry a failed API call

#configure AWS S3
@dataclass(frozen=True)
class S3Config:
    bucket_name: str = os.getenv("S3_BUCKET_NAME", "")
    prefix: str = "raw/shelter_occupancy"
    region: str = os.getenv("AWS_DEFAULT_REGION", "us-east-1")


API_CONFIG = APIConfig()
S3_CONFIG = S3Config()

#
def setup_logging(level: int = logging.INFO) -> logging.Logger:
    logging.basicConfig(
        level=level,
        format="%(asctime)s | %(levelname)-8s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    return logging.getLogger("shelter_occupancy_pipeline")


