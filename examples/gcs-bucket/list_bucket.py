# /// script
# dependencies = ["google-cloud-storage"]
# ///
"""List objects in a GCS bucket. Reads bucket name from terraform outputs.json."""

import json
import sys

from google.cloud import storage


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <outputs.json>", file=sys.stderr)
        sys.exit(1)

    with open(sys.argv[1]) as f:
        outputs = json.load(f)

    bucket_name = outputs["bucket_name"]["value"]
    client = storage.Client()
    bucket = client.bucket(bucket_name)

    print(f"Objects in gs://{bucket_name}:")
    for blob in bucket.list_blobs():
        print(f"  {blob.name}")


if __name__ == "__main__":
    main()
