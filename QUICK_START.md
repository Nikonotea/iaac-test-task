# Quick Validation Cheatsheet

## 1. Local check (without AWS) - 2 minutes

```bash
# In project root
make fmt      # formatting
make validate # validation
make checks   # full check
```

## 2. Docker Compose - 2 minutes

```bash
# Copy .env file
cp .env.example infra/.env

# Start services
cd infra
docker-compose up -d --build
sleep 10

# Check
curl http://localhost:5000/health     # backend
curl http://localhost/                 # frontend
curl http://localhost:5000/           # api

# Stop
docker-compose down -v
```

## 3. Full validation

```bash
# In project root
make validate-all

# Or manually run the script
./VALIDATION.sh
```

## 4. AWS deployment (requires AWS credentials)

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."

cd terraform/envs/dev
terraform init
terraform plan
terraform apply
```

## 5. Tests (requires AWS credentials)

```bash
cd tests/terratest
go mod tidy
go test -v -timeout 30m
```

## Configuration files

| File | Copy from | Status |
|------|---|---|
| `infra/.env` | `.env.example` | ⚠️ in .gitignore |
| `terraform/envs/dev/terraform.tfvars` | `terraform.tfvars.example` | ⚠️ in .gitignore |

## Help

```bash
make help
cat VALIDATION_GUIDE.md
```
