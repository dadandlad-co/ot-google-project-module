# Makefile for OpenTofu Google Project Module
# Alternative to Taskfile for teams that prefer Make

.PHONY: help dev-setup validate test fmt docs clean security-scan

# Default target
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

dev-setup: ## Set up development environment
	@echo "Setting up development environment..."
	@direnv allow
	@pre-commit install
	@echo "Development environment ready!"

validate: ## Validate all modules and examples
	@echo "Validating modules..."
	@for dir in modules/project modules/billing modules/billing-budget; do \
		if [ -d "$$dir" ]; then \
			echo "Validating $$dir"; \
			cd "$$dir" && tofu init -backend=false && tofu validate && tofu fmt -check && cd - > /dev/null; \
		fi; \
	done
	@echo "Validating examples..."
	@for dir in examples/simple examples/complete; do \
		if [ -d "$$dir" ]; then \
			echo "Validating $$dir"; \
			cd "$$dir" && tofu init -backend=false && tofu validate && tofu fmt -check && cd - > /dev/null; \
		fi; \
	done

test: ## Run all tests
	@echo "Running tests..."
	@$(MAKE) test-simple
	@$(MAKE) test-complete

test-simple: ## Test simple example
	@echo "Testing simple example..."
	@cd examples/simple && \
		tofu init && \
		tofu plan -var="project_id=test-simple-$$(date +%s)" -out=tfplan && \
		echo "Simple example validation: PASSED"

test-complete: ## Test complete example
	@echo "Testing complete example..."
	@cd examples/complete && \
		tofu init && \
		tofu plan -var="project_id=test-complete-$$(date +%s)" -out=tfplan && \
		echo "Complete example validation: PASSED"



fmt: ## Format all OpenTofu files
	@echo "Formatting all files..."
	@tofu fmt -recursive .
	@echo "All files formatted"

docs: ## Generate documentation
	@echo "Generating documentation..."
	@for dir in modules/project modules/billing modules/billing-budget; do \
		if [ -d "$$dir" ]; then \
			echo "Generating docs for $$dir"; \
			cd "$$dir" && terraform-docs markdown . > README.md && cd - > /dev/null; \
		fi; \
	done

security-scan: ## Run security scans
	@echo "Running security scans..."
	@trufflehog git file://. --since-commit HEAD --only-verified --fail
	@tfsec . --soft-fail
	@checkov -d . --framework terraform --soft-fail

pre-commit: ## Run pre-commit hooks
	@pre-commit autoupdate
	@pre-commit run -a



clean: ## Clean up temporary files
	@echo "Cleaning up..."
	@find . \( \
		-name '*.HOLD' -o \
		-type d -name '.terraform' -o \
		-type f -name '*.tfstate*' -o \
		-type f -name '.terraform.lock.hcl' -o \
		-type f -name 'tfplan' \
	\) -exec rm -rf {} + 2>/dev/null || true
	@echo "Clean completed"
