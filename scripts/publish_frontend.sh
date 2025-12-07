#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUCKET=${1:-}
if [ -z "$BUCKET" ]; then
  echo "Usage: $0 <s3-bucket-name>"
  exit 2
fi

echo "Building frontend and syncing to s3://$BUCKET"
cd "$ROOT/app/frontend"
# frontend is static files in this demo
aws s3 sync . "s3://$BUCKET" --acl private --delete
echo "Frontend published to s3://$BUCKET"
