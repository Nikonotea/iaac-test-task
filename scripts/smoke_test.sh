#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <url>"
  echo "Example: $0 https://d1234abcdef.cloudfront.net"
  exit 2
fi

URL=${1}

echo "Checking ${URL}..."

HTTP_ROOT=$(curl -s -o /dev/null -w "%{http_code}" "${URL}/")
if [ "$HTTP_ROOT" = "200" ]; then
  echo "OK: ${URL}/ returned 200"
else
  echo "FAIL: ${URL}/ returned ${HTTP_ROOT}"
  exit 1
fi

HTTP_API=$(curl -s -o /dev/null -w "%{http_code}" "${URL}/api/health")
if [ "$HTTP_API" = "200" ]; then
  echo "OK: ${URL}/api/health returned 200"
else
  echo "WARN: ${URL}/api/health returned ${HTTP_API} (api may be behind proxy)"
fi

echo "Smoke test passed."
