#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Bootstrapping remote state resources (S3 bucket + DynamoDB table)..."
cd "$ROOT/terraform/bootstrap/backend"
terraform init
terraform apply -auto-approve

BUCKET=$(terraform output -raw bucket)
DYNAMO=$(terraform output -raw dynamodb_table)

cat <<EOF
Bootstrap complete.
S3 bucket: $BUCKET
DynamoDB table: $DYNAMO

To enable remote state for 'dev' environment, add the following to 'terraform/envs/dev/backend.tf' (or create it):

terraform {
  backend "s3" {
    bucket         = "$BUCKET"
    key            = "iaac-test-task/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "$DYNAMO"
    encrypt        = true
  }
}

Then run in terraform/envs/dev:

1) terraform init -reconfigure
2) terraform plan

Note: moving existing local state to remote requires 'terraform state push' or manual 'terraform init -migrate-state' workflow. Read the Terraform docs before migrating production state.
EOF
