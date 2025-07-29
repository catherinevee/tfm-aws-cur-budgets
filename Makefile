# Makefile for AWS Budgets and Cost Usage Reports Terraform Module

.PHONY: help init plan apply destroy validate fmt lint clean test examples

# Default target
help:
	@echo "Available targets:"
	@echo "  init      - Initialize Terraform"
	@echo "  plan      - Plan Terraform changes"
	@echo "  apply     - Apply Terraform changes"
	@echo "  destroy   - Destroy Terraform resources"
	@echo "  validate  - Validate Terraform configuration"
	@echo "  fmt       - Format Terraform code"
	@echo "  lint      - Lint Terraform code"
	@echo "  clean     - Clean up temporary files"
	@echo "  test      - Run tests"
	@echo "  examples  - Run examples"

# Initialize Terraform
init:
	terraform init

# Plan Terraform changes
plan:
	terraform plan

# Apply Terraform changes
apply:
	terraform apply

# Destroy Terraform resources
destroy:
	terraform destroy

# Validate Terraform configuration
validate:
	terraform validate

# Format Terraform code
fmt:
	terraform fmt -recursive

# Lint Terraform code (requires tflint)
lint:
	@if command -v tflint >/dev/null 2>&1; then \
		tflint --init; \
		tflint; \
	else \
		echo "tflint not found. Install with: go install github.com/terraform-linters/tflint/cmd/tflint@latest"; \
	fi

# Clean up temporary files
clean:
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate
	rm -f terraform.tfstate.backup
	rm -rf .terraform.tfstate.lock.info

# Run tests (requires terratest)
test:
	@if command -v go >/dev/null 2>&1; then \
		cd test && go test -v -timeout 30m; \
	else \
		echo "Go not found. Install Go to run tests."; \
	fi

# Run examples
examples:
	@echo "Running basic example..."
	@cd examples/basic && terraform init && terraform plan
	@echo "Running advanced example..."
	@cd examples/advanced && terraform init && terraform plan

# Install development tools
install-tools:
	@echo "Installing development tools..."
	@if command -v go >/dev/null 2>&1; then \
		go install github.com/terraform-linters/tflint/cmd/tflint@latest; \
		go install github.com/gruntwork-io/terratest/modules/terratest@latest; \
	else \
		echo "Go not found. Install Go first."; \
	fi

# Check for security issues (requires terrascan)
security-scan:
	@if command -v terrascan >/dev/null 2>&1; then \
		terrascan scan; \
	else \
		echo "terrascan not found. Install with: curl -L \"\$$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E 'https://github.com/tenable/terrascan/releases/download/v[0-9]+\.[0-9]+\.[0-9]+/terrascan_[0-9]+\.[0-9]+\.[0-9]+_Linux_x86_64.tar.gz')\" | tar -xz terrascan && sudo mv terrascan /usr/local/bin/"; \
	fi

# Documentation
docs:
	@echo "Generating documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table . > README.md.tmp; \
		echo "Documentation updated in README.md.tmp"; \
	else \
		echo "terraform-docs not found. Install with: go install github.com/terraform-docs/terraform-docs@latest"; \
	fi 