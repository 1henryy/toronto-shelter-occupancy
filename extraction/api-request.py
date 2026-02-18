from ckanapi import RemoteCKAN
from ckanapi.errors import CKANAPIError

BASE_URL = "https://ckan0.cf.opendata.inter.prod-toronto.ca"
RESOURCE_ID = "42714176-4f05-44e6-b157-2b57f29b856a"

def fetch_data(limit=5):
    try:
        ckan = RemoteCKAN(BASE_URL)
        response = ckan.action.datastore_search(
            id=RESOURCE_ID,
            limit=limit
        )
        return response["records"]
    except CKANAPIError as e:
        raise RuntimeError(f"CKAN query failed: {e}")

if __name__ == "__main__":
    records = fetch_data(limit=5)
    for r in records:
        print(r)
