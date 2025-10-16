.PHONY: help clean lint test molecule molecule-test format \
	molecule-test molecule-2204-no-uv molecule-2404-no-uv molecule-2404-uv

molecule ?= molecule

help: ## Display this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

lint: yamllint ansible-lint
	@echo "All linting completed!"

yamllint: ## Run YAML linting
	@echo "Running yamllint..."
	yamllint .

ansible-lint: ## Run Ansible linting
	@echo "Running ansible-lint..."
	ansible-lint

format: ## Format code with black and other formatters
	@echo "Formatting Python code..."
	black tests/ --line-length 88 --target-version py39
	@echo "Code formatting completed!"

test: lint molecule ## Run default test suite (lint + default molecule scenario)
	@echo "Default testing completed!"

molecule-2204-no-uv:
	@echo "==> molecule: ubuntu-22.04 (no uv)"; \
	LOG=molecule-2204-no-uv.log; \
	( MOLECULE_UBUNTU_VERSION=2204 PYTHON_UV_INSTALL=false $(molecule) test -s default 2>&1 | tee $$LOG ) || ( echo "FAILED: see $$LOG"; cat $$LOG; false )

molecule-2404-no-uv:
	@echo "==> molecule: ubuntu-24.04 (no uv)"; \
	LOG=molecule-2404-no-uv.log; \
	( MOLECULE_UBUNTU_VERSION=2404 PYTHON_UV_INSTALL=false $(molecule) test -s default 2>&1 | tee $$LOG ) || ( echo "FAILED: see $$LOG"; cat $$LOG; false )

molecule-2404-uv:
	@echo "==> molecule: ubuntu-24.04 (with uv)"; \
	LOG=molecule-2404-uv.log; \
	( MOLECULE_UBUNTU_VERSION=2404 PYTHON_UV_INSTALL=true PYTHON_UV_SUFFIX="-alt" $(molecule) test -s default 2>&1 | tee $$LOG ) || ( echo "FAILED: see $$LOG"; cat $$LOG; false )

molecule:
	@echo "Running all molecule scenarios..."
	make -j molecule-test

molecule-test: molecule-2404-uv molecule-2404-no-uv molecule-2204-no-uv

molecule-destroy:
	@echo "Removing molecule instances"
	molecule destroy

clean: molecule-destroy ## Clean up molecule instances and temporary files
	@echo "Cleaning up..."
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name ".pytest_cache" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "Cleanup completed!"
