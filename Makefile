.PHONY: fmt validate bootstrap publish smoke checks validate-all help

fmt:
	terraform fmt -recursive

validate:
	cd terraform/envs/dev && terraform init -backend=false && terraform validate

bootstrap:
	chmod +x scripts/bootstrap-remote-state.sh && scripts/bootstrap-remote-state.sh

publish:
	# publish frontend to given bucket: make publish BUCKET=name
	@if [ -z "$(BUCKET)" ]; then echo "Usage: make publish BUCKET=<bucket-name>"; exit 2; fi
	chmod +x scripts/publish_frontend.sh && scripts/publish_frontend.sh $(BUCKET)

smoke:
	# smoke test against CloudFront domain: make smoke URL=https://...
	@if [ -z "$(URL)" ]; then echo "Usage: make smoke URL=<cloudfront-domain>"; exit 2; fi
	chmod +x scripts/smoke_test.sh && scripts/smoke_test.sh $(URL)

checks:
	chmod +x scripts/run_checks.sh && ./scripts/run_checks.sh

validate-all:
	chmod +x VALIDATION.sh && ./VALIDATION.sh

help:
	@echo "Available targets:"
	@echo "  make fmt              - Format all Terraform files"
	@echo "  make validate         - Validate Terraform config"
	@echo "  make checks           - Run all checks (fmt, validate, tfsec, checkov)"
	@echo "  make validate-all     - Full project validation (docker, terraform, tests)"
	@echo "  make bootstrap        - Create S3 + DynamoDB for remote state"
	@echo "  make publish BUCKET=  - Publish frontend to S3 bucket"
	@echo "  make smoke URL=       - Smoke test CloudFront domain"
	@echo "  make help             - Show this help message"
