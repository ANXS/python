
.PHONY: help clean lint test format act act-download distclean

ACT_VERSION ?= 0.2.82
ACT_BINARY := $(shell pwd)/.act/act
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

molecule-2204-no-uv:
       @echo "molecule: ubuntu-22.04 (no uv)"
       LOG=molecule-2204-no-uv.log; \
       ( MOLECULE_UBUNTU_VERSION=2204 PYTHON_UV_INSTALL=false $(molecule) test -s default 2>&1 | tee $$LOG ) || ( echo "FAILED: see $$LOG"; cat $$LOG; false )

molecule-2404-no-uv:
       @echo "molecule: ubuntu-24.04 (no uv)"
       LOG=molecule-2404-no-uv.log; \
       ( MOLECULE_UBUNTU_VERSION=2404 PYTHON_UV_INSTALL=false $(molecule) test -s default 2>&1 | tee $$LOG ) || ( echo "FAILED: see $$LOG"; cat $$LOG; false )

molecule-2404-uv:
       @echo "molecule: ubuntu-24.04 (with uv)"
       LOG=molecule-2404-uv.log; \
       ( MOLECULE_UBUNTU_VERSION=2404 PYTHON_UV_INSTALL=true PYTHON_UV_SUFFIX="-alt" $(molecule) test -s default 2>&1 | tee $$LOG ) || ( echo "FAILED: see $$LOG"; cat $$LOG; false )

act-download: ## download act
	@if [ ! -f "$(ACT_BINARY)" ]; then \
		@echo "Downloading act..." ; \
		mkdir -p $(shell pwd)/.act ; \
		curl -L https://github.com/nektos/act/releases/download/v$(ACT_VERSION)/act_Linux_x86_64.tar.gz | tar -xz -C $(shell pwd)/.act act ; \
	fi

molecule: molecule-2404-uv molecule-2404-no-uv molecule-2204-no-uv

test: act-download ## Run GitHub workflows, but locally
	@echo "Running Tests!"
	$(ACT_BINARY)

clean: molecule-destroy ## Clean up molecule instances and temporary files
	@echo "Cleaning up..."
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name ".pytest_cache" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "Cleanup completed!"

distclean: clean
	@echo "Dist cleaning..."
	rm -rf $(shell pwd)/.act
