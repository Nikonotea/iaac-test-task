# iaac-test-task

This is a demo project includes the follofing: Terraform modules for VPC, EC2, RDS and CloudFront (S3), plus Docker Compose and Nginx config to run a simple application on an EC2-like instance.

Purpose and scope:
- Show modular Terraform layout and best practices for a small infra project.
- Provide a local demo via Docker Compose and a minimal app (backend + frontend).
- Include basic CI checks, static scanners and an example monitoring setup.

Key components:
- Terraform modules: `terraform/modules/vpc`, `terraform/modules/ec2_app`, `terraform/modules/rds`, `terraform/modules/cloudfront`, `terraform/modules/monitoring`.
- Environment example: `terraform/envs/dev`.
- Local demo: `infra/docker-compose.yml` and `infra/nginx/nginx.conf` to run the stack on a VM/EC2.
- Minimal sample app: `app/backend` (Flask) and `app/frontend` (static nginx).
- CI: `.github/workflows/ci.yml` — runs `terraform fmt`, `terraform validate`, `tfsec`, `checkov`.
- Local checks: `scripts/run_checks.sh` runs format/validate and optional security scanners.
- Terratest: `tests/terratest/` contains Go unit tests for Terraform modules (VPC, EC2, RDS, CloudFront).

Quickstart — run locally (Docker Compose):

```bash
cd infra
docker-compose up --build
```

The frontend will be available at `http://localhost` and the backend at `http://localhost:5000` (API prefix `/api/`).

Quickstart — Terraform checks locally:

```bash
chmod +x scripts/run_checks.sh
./scripts/run_checks.sh
```

Publishing frontend to S3 (used by CloudFront OAI):

```bash
# Build/publish frontend to the bucket created by Terraform or the bootstrap module
chmod +x scripts/publish_frontend.sh
./scripts/publish_frontend.sh <your-frontend-bucket-name>
```

Bootstrapping remote state (S3 + DynamoDB):

```bash
# This will create an S3 bucket and DynamoDB table in terraform/bootstrap/backend
chmod +x scripts/bootstrap-remote-state.sh
./scripts/bootstrap-remote-state.sh
```

After bootstrap, follow the script's printed snippet to configure `terraform/envs/dev/backend.tf` and run `terraform init -reconfigure` in `terraform/envs/dev`.


Minimal AWS deploy:

Prerequisites:
- AWS account and credentials configured in your environment (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, optional `AWS_REGION`).

Steps:

1) From repo root, format and validate Terraform (run from repo root, not in terraform/envs/dev):

```bash
make fmt
make validate
```

2) Initialize and plan the dev environment (from repo root):

```bash
cd terraform/envs/dev
terraform init
terraform plan
```

3) Apply the plan (creates VPC, EC2, RDS, CloudFront):

```bash
terraform apply
```

Note the outputs (instance IP, RDS endpoint, CloudFront domain, frontend bucket name).

4) Publish frontend static files to the S3 bucket (from repo root):

```bash
cd ../..  # back to repo root
make publish BUCKET=<your-frontend-bucket-name>
```

5) Smoke test the CloudFront domain (from repo root):

```bash
make smoke URL=https://<your-cloudfront-domain>
```

For team workflows, bootstrap remote state first (optional):

```bash
# From repo root
make bootstrap
# Follow the printed instructions to enable S3 backend
```

## Common Commands (from repo root)

All Makefile commands should be run from **repo root**, not from subdirectories.

| Command | Purpose |
|---------|---------|
| `make fmt` | Format all Terraform files |
| `make validate` | Validate Terraform config (init + validate) |
| `make checks` | Run local checks (terraform fmt, validate, tfsec, checkov) |
| `make bootstrap` | Create S3 + DynamoDB for remote state (optional) |
| `make publish BUCKET=<name>` | Publish frontend to S3 bucket |
| `make smoke URL=<domain>` | Run HTTP smoke test against CloudFront domain |

Running Terratest unit tests (requires AWS credentials + Go 1.20+):

```bash
cd tests/terratest
go mod download
go test -v -timeout 30m
```

Example workflow:

```bash
cd /path/to/iaac-test-task  # repo root

# Verify config locally
make fmt
make validate

# Deploy to AWS (requires credentials)
cd terraform/envs/dev
terraform init
terraform plan
terraform apply

# Back to repo root
cd ../..
make publish BUCKET=$(terraform -chdir=terraform/envs/dev output -raw frontend_bucket)
make smoke URL=$(terraform -chdir=terraform/envs/dev output -raw cdn_domain)
```