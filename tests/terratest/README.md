# Terratest Unit Tests

This directory contains Terratest (Go) unit tests for Terraform modules.

## Prerequisites

- Go 1.20+
- Terraform
- AWS credentials (for running tests against AWS)

## Running Tests

From the repo root:

```bash
cd tests/terratest

# Download dependencies (go mod tidy)
go mod download

# Run all tests (requires AWS credentials)
go test -v -timeout 30m

# Run a specific test
go test -v -timeout 30m -run TestVPCModule
```

## Test Files

- `vpc_test.go` — Tests VPC module outputs (VPC ID, subnets)
- `ec2_test.go` — Tests EC2 module (instance ID, security group)
- `rds_test.go` — Tests RDS module (database endpoint)
- `cloudfront_test.go` — Tests CloudFront + S3 module (bucket, CDN domain)
- `helpers.go` — Utility functions (random string generation)

## Best Practices

- Tests use `t.Parallel()` for concurrent execution (faster runs).
- Tests clean up resources with `defer terraform.Destroy()`.
- Each test verifies key outputs and assertions (non-empty, format checks).
- Tests use randomized names (e.g., S3 bucket names) to avoid conflicts.

## CI Integration

Tests can be added to `.github/workflows/ci.yml` to run on every push/PR:

```yaml
- name: Run Terratest
  run: |
    cd tests/terratest
    go test -v -timeout 30m
```

Note: This requires AWS credentials in the CI environment (GitHub Secrets).
