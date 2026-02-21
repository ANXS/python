.PHONY: lint test test-ubuntu2204 test-ubuntu2404 test-ubuntu2404-uv test-debian13 test-debian13-uv test-all act act-download clean distclean

VENV := .venv
BIN := $(VENV)/bin
export PATH := $(CURDIR)/$(BIN):$(PATH)

$(VENV): requirements-dev.txt
	python3 -m venv $(VENV)
	$(BIN)/pip install --upgrade pip
	$(BIN)/pip install -r requirements-dev.txt
	@touch $(VENV)

lint: $(VENV)
	$(BIN)/yamllint -c .yamllint defaults tasks vars meta handlers
	$(BIN)/ansible-lint -c .ansible-lint defaults tasks vars meta handlers

test: lint test-all

test-ubuntu2204: $(VENV)
	MOLECULE_OS=ubuntu MOLECULE_VERSION=2204 \
		PYTHON_UV_INSTALL=false \
		$(BIN)/molecule test

test-ubuntu2404: $(VENV)
	MOLECULE_OS=ubuntu MOLECULE_VERSION=2404 \
		PYTHON_UV_INSTALL=false \
		$(BIN)/molecule test

test-ubuntu2404-uv: $(VENV)
	MOLECULE_OS=ubuntu MOLECULE_VERSION=2404 \
		PYTHON_UV_INSTALL=true PYTHON_UV_SUFFIX="-uv" \
		$(BIN)/molecule test

test-debian13: $(VENV)
	MOLECULE_OS=debian MOLECULE_VERSION=13 \
		PYTHON_UV_INSTALL=false \
		$(BIN)/molecule test

test-debian13-uv: $(VENV)
	MOLECULE_OS=debian MOLECULE_VERSION=13 \
		PYTHON_UV_INSTALL=true PYTHON_UV_SUFFIX="-uv" \
		$(BIN)/molecule test

test-all: test-ubuntu2204 test-ubuntu2404 test-ubuntu2404-uv test-debian13 test-debian13-uv

ACT_VERSION ?= 0.2.82
ACT_BINARY := $(CURDIR)/.act/act

act-download:
	@if [ ! -f "$(ACT_BINARY)" ]; then \
		echo "Downloading act v$(ACT_VERSION)..." ; \
		mkdir -p $(CURDIR)/.act ; \
		curl -sL https://github.com/nektos/act/releases/download/v$(ACT_VERSION)/act_Linux_x86_64.tar.gz | tar -xz -C $(CURDIR)/.act act ; \
	fi

act: act-download ## Run GitHub workflows locally via act
	$(ACT_BINARY)

clean:
	$(BIN)/molecule destroy 2>/dev/null || true

distclean: clean
	rm -rf $(VENV) .act
