#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Running local checks..."
cd "$ROOT/terraform/envs/dev"
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
if command -v tfsec >/dev/null 2>&1; then
  tfsec . || true
else
  echo "tfsec not installed, skipping"
fi
if command -v checkov >/dev/null 2>&1; then
  checkov -d ../.. || true
else
  echo "checkov not installed, skipping"
fi

echo "All checks finished (errors from scanners are non-fatal by design)."
