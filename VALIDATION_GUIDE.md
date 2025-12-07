# Project Validation Checklist

## Quick Start (3 minutes)

### 1. Environment setup
```bash
# Navigate to the project root
cd /path/to/iaac-test-task

# Copy the .env file (for docker-compose)
cp .env.example infra/.env
```

### 2. Terraform check
```bash
# Formatting (from project root)
make fmt

# Validation (from project root)
make validate

# Local checks (fmt + validate + tfsec + checkov)
make checks
```

### 3. Start local environment (Docker Compose)
```bash
# Go to the infra folder
cd infra

# Start containers
docker-compose up -d --build

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### 4. Service checks
```bash
# Backend health check
curl http://localhost:5000/health
# Expected result: {"status": "ok"}

# Frontend
curl http://localhost/
# Expected: HTML page with "Test Assignment Frontend"

# API endpoint
curl http://localhost:5000/
# Expected result: {"message": "Hello from backend"}
```

### 5. Stop services
```bash
# From infra folder
docker-compose down -v
```

---

## Full validation (5-10 minutes)

### Option 1: Use the script
```bash
# From project root
chmod +x VALIDATION.sh
./VALIDATION.sh
```

### Option 2: Manual steps

#### Step 1: Terraform Format
```bash
cd /path/to/iaac-test-task
terraform fmt -recursive
# Should complete without errors
```

#### Step 2: Terraform Validate
```bash
cd terraform/envs/dev
terraform init -backend=false
terraform validate
# Should output: Success! The configuration is valid.
```

#### Step 3: Security Scanning (optional)
```bash
# From project root

# tfsec
tfsec terraform --format json

# checkov
checkov -d terraform --framework terraform
```

#### Step 4: Docker Compose
```bash
cd infra

# Create .env if it doesn't exist
[ ! -f .env ] && cp ../.env.example .env

# Clean up old containers
docker-compose down -v

# Start new ones
docker-compose up -d --build

# Wait for DB initialization (10 sec)
sleep 10

# Check containers
docker-compose ps
```

#### Step 5: Health Checks
```bash
# Backend health
curl -v http://localhost:5000/health
# Expected: 200 OK, {"status": "ok"}

# Frontend
curl -v http://localhost/
# Expected: 200 OK, HTML content

# Backend API
curl -v http://localhost:5000/
# Expected: 200 OK, {"message": "Hello from backend"}
```

#### Step 6: Terratest (requires AWS credentials)
```bash
cd tests/terratest

# Resolve dependencies
go mod tidy

# Run tests
go test -v -timeout 30m

# Or specific test
go test -v -timeout 30m -run TestVPCModule
```

---

## AWS Deployment (requires AWS credentials)

### Preparation
```bash
# Set AWS credentials
export AWS_ACCESS_KEY_ID="your_key_here"
export AWS_SECRET_ACCESS_KEY="your_secret_here"
export AWS_REGION="us-east-1"

# Or use AWS CLI credentials file
aws configure
```

### Deployment
```bash
cd terraform/envs/dev

# Initialize
terraform init

# Plan (what will be created)
terraform plan -out=tfplan

# Apply (create resources in AWS)
terraform apply tfplan

# Get outputs
terraform output
```

### Publish frontend
```bash
# From project root
BUCKET=$(terraform -chdir=terraform/envs/dev output -raw frontend_bucket)
make publish BUCKET=$BUCKET
```

### Smoke test CDN
```bash
DOMAIN=$(terraform -chdir=terraform/envs/dev output -raw cdn_domain)
make smoke URL=https://$DOMAIN
```

---

## Configuration files

| File | Description |
|------|---------||
| `.env.example` | Example environment variables (committed) |
| `infra/.env` | Real variables for docker-compose (in .gitignore) |
| `.gitignore` | Excludes .env, *.tfstate, *.pem, etc. |
| `terraform/envs/dev/terraform.tfvars.example` | Example Terraform variables |
| `terraform/envs/dev/terraform.tfvars` | Real variables (in .gitignore) |

---

## Troubleshooting

### Docker Compose error: "database does not exist"
```bash
# Solution: clean volumes and restart
cd infra
docker-compose down -v
docker-compose up -d --build
sleep 10
```

### Terraform: "Error: Invalid provider configuration"
```bash
# Solution: initialize without backend
cd terraform/envs/dev
terraform init -backend=false
```

### Terraform: "No valid credential sources found"
```bash
# Solution: set AWS credentials
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
# or
aws configure
```

### Backend cannot connect to DB
```bash
# Check variables in infra/.env
cat infra/.env

# Check DB logs
cd infra && docker-compose logs db
```

---

## Makefile commands (from project root)

```bash
make fmt              # Format all .tf files
make validate         # Validate Terraform
make checks           # fmt + validate + tfsec + checkov
make bootstrap        # Create S3 + DynamoDB for remote state
make publish BUCKET=name  # Publish frontend to S3
make smoke URL=domain     # Smoke test CloudFront
```

---

## Project files

```
iaac-test-task/
├── .env.example                          # Example environment variables
├── .gitignore                            # Git ignore rules
├── .github/workflows/ci.yml              # GitHub Actions CI/CD
├── VALIDATION.sh                         # Full validation script
├── Makefile                              # Convenient commands
├── README.md                             # Main documentation
├── app/
│   ├── backend/
│   │   ├── Dockerfile
│   │   ├── app.py
│   │   └── requirements.txt
│   └── frontend/
│       ├── Dockerfile
│       └── index.html
├── infra/
│   ├── .env                              # (in .gitignore) Docker variables
│   ├── .env.example                      # Example
│   ├── docker-compose.yml
│   └── nginx/
│       └── nginx.conf
├── scripts/
│   ├── bootstrap-remote-state.sh
│   ├── publish_frontend.sh
│   ├── run_checks.sh
│   └── smoke_test.sh
├── terraform/
│   ├── versions.tf
│   ├── providers.tf
│   ├── bootstrap/
│   │   └── backend/
│   │       ├── main.tf
│   │       └── variables.tf
│   ├── modules/
│   │   ├── cloudfront/
│   │   ├── ec2_app/
│   │   ├── monitoring/
│   │   ├── rds/
│   │   └── vpc/
│   └── envs/
│       └── dev/
│           ├── .terraform/
│           ├── .env                      # (in .gitignore)
│           ├── terraform.tfvars          # (in .gitignore)
│           ├── terraform.tfvars.example
│           ├── backend.tf
│           ├── main.tf
│           ├── providers.tf
│           └── variables.tf
└── tests/
    └── terratest/
        ├── go.mod
        ├── go.sum
        ├── cloudfront_test.go
        ├── ec2_test.go
        ├── helpers.go
        ├── main_test.go
        ├── rds_test.go
        └── vpc_test.go
```

---

## Summary

✅ **Local validation** (without AWS credentials):
1. `make fmt` - formatting
2. `make validate` - validation
3. `cd infra && docker-compose up --build` - start services
4. `curl http://localhost:5000/health` - check

✅ **With AWS credentials**:
1. All of the above
2. `cd terraform/envs/dev && terraform init && terraform plan`
3. `tests/terratest`: `go test -v -timeout 30m`

✅ **CI/CD (GitHub Actions)**:
- Automatically on every push and PR
- Includes: lint, format check, security scan, unit tests, docker build, integration tests
