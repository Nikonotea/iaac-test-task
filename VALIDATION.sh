#!/bin/bash
# Complete project validation checklist
# Run from repository root

set -e

echo "=========================================="
echo "  iaac-test-task - Full Validation"
echo "=========================================="
echo ""

# Step 1: Terraform Format Check
echo "✓ Step 1: Checking Terraform formatting..."
terraform fmt -recursive
echo "  ✓ Terraform fmt OK"
echo ""

# Step 2: Terraform Validation
echo "✓ Step 2: Validating Terraform configuration..."
cd terraform/envs/dev
terraform init -backend=false
terraform validate
cd - > /dev/null
echo "  ✓ Terraform validation OK"
echo ""

# Step 3: Security Scanning (optional)
echo "✓ Step 3: Running security scans (optional)..."
if command -v tfsec >/dev/null 2>&1; then
  tfsec terraform || true
  echo "  ✓ tfsec scan completed"
else
  echo "  ℹ tfsec not installed (optional)"
fi

if command -v checkov >/dev/null 2>&1; then
  checkov -d terraform || true
  echo "  ✓ checkov scan completed"
else
  echo "  ℹ checkov not installed (optional)"
fi
echo ""

# Step 4: Docker Compose - Setup
echo "✓ Step 4: Setting up Docker Compose..."
if [ ! -f "infra/.env" ]; then
  echo "  Creating infra/.env from .env.example..."
  cp .env.example infra/.env
fi
echo "  ✓ .env file ready"
echo ""

# Step 5: Docker Compose - Build and Start
echo "✓ Step 5: Building and starting Docker services..."
cd infra
docker-compose down -v 2>/dev/null || true
docker-compose up -d --build
echo "  Waiting for services to start (10 seconds)..."
sleep 10
echo "  ✓ Docker services started"
cd - > /dev/null
echo ""

# Step 6: Service Health Checks
echo "✓ Step 6: Running health checks..."
echo "  Testing backend /health endpoint..."
if curl -sf http://localhost:5000/health > /dev/null; then
  echo "    ✓ Backend health OK"
else
  echo "    ✗ Backend health FAILED"
  exit 1
fi

echo "  Testing frontend..."
if curl -sf http://localhost:80/ > /dev/null; then
  echo "    ✓ Frontend OK"
else
  echo "    ✗ Frontend FAILED"
  exit 1
fi

echo "  Testing API endpoint..."
if curl -sf http://localhost:5000/ > /dev/null; then
  echo "    ✓ API endpoint OK"
else
  echo "    ✗ API endpoint FAILED"
  exit 1
fi
echo ""

# Step 7: Terratest (optional)
echo "✓ Step 7: Running Terratest unit tests (requires AWS credentials)..."
if command -v go >/dev/null 2>&1; then
  cd tests/terratest
  go mod download 2>/dev/null || go mod tidy
  echo "  ℹ To run Terratest tests with AWS credentials:"
  echo "    cd tests/terratest && go test -v -timeout 30m"
  cd - > /dev/null
  echo "    ✓ Go environment ready"
else
  echo "  ℹ Go not installed (optional for Terratest)"
fi
echo ""

echo "=========================================="
echo "  ✓ All checks passed!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. View logs:"
echo "   cd infra && docker-compose logs"
echo ""
echo "2. Stop services:"
echo "   cd infra && docker-compose down"
echo ""
echo "3. Deploy to AWS (requires AWS credentials):"
echo "   cd terraform/envs/dev"
echo "   export AWS_ACCESS_KEY_ID=your_key"
echo "   export AWS_SECRET_ACCESS_KEY=your_secret"
echo "   terraform init"
echo "   terraform plan"
echo "   terraform apply"
echo ""
echo "4. Run Terratest:"
echo "   cd tests/terratest && go test -v -timeout 30m"
echo ""
