include mk/go.mk
include mk/lint.mk
# NOTE: rust.mk is included upstream

## Setup development environment
.PHONY: setup
setup:
ifeq ($(OS),Windows_NT)
	@powershell -ExecutionPolicy Bypass -File scripts/setup-windows.ps1
else
	@bash scripts/setup-unix.sh
endif

## Build all components (Windows-compatible)
.PHONY: build-all
build-all:
ifeq ($(OS),Windows_NT)
	@powershell -ExecutionPolicy Bypass -File scripts/build-windows.ps1
else
	@make rust && make install
endif

## Clean build artifacts
.PHONY: clean-all
clean-all:
ifeq ($(OS),Windows_NT)
	@powershell -ExecutionPolicy Bypass -File scripts/build-windows.ps1 -Clean
else
	@make clean
endif

.PHONY: help
help:
	@echo "Available targets:"
	@echo
	@awk '/^## / { \
		helpMessage = substr($$0, 4); \
		getline; \
		if ($$1 == ".PHONY:") { \
			getline; \
		} \
		sub(/:.*/, "", $$1); \
		printf "  %-30s %s\n", $$1, helpMessage; \
	}' $(MAKEFILE_LIST)

## Install the stork-generate binary
.PHONY: install-stork-generate
install-stork-generate:
	@echo "Installing stork-generate..."
	@echo "Running: go build -o $(shell go env GOPATH)/bin/stork-generate ./utils/generate"
	@go build -o $(shell go env GOPATH)/bin/stork-generate ./utils/generate
	@if [ -f "./apps/scripts/animate.sh" ]; then ./apps/scripts/animate.sh; fi
	@echo "Successfully installed stork-generate. Run 'stork-generate help' to get started."

## Uninstall the stork-generate binary
.PHONY: uninstall-stork-generate
uninstall-stork-generate:
	@echo "Uninstalling stork-generate..."
	@echo "Running: rm -f $(shell go env GOPATH)/bin/stork-generate"
	@rm -f $(shell go env GOPATH)/bin/stork-generate
	@echo "Successfully uninstalled stork-generate"

## Install the data-provider binary
.PHONY: install-data-provider
install-data-provider:
	@echo "Installing data-provider..."
	@echo "Running: go build -o $(shell go env GOPATH)/bin/data-provider ./apps/data_provider"
	@go build -o $(shell go env GOPATH)/bin/data-provider ./apps/data_provider
	@echo "Successfully installed data-provider. Run 'data-provider help' to get started."

## Uninstall the data-provider binary
.PHONY: uninstall-data-provider
uninstall-data-provider:
	@echo "Uninstalling data-provider..."
	@rm -f $(shell go env GOPATH)/bin/data-provider
	@echo "Successfully uninstalled data-provider"

## Rebuild and reinstall the data-provider binary
.PHONY: rebuild-data-provider
rebuild-data-provider: uninstall-data-provider install-data-provider
	@echo "Successfully rebuilt data-provider"

## Start the data provider (rebuilds first)
.PHONY: start-data-provider
start-data-provider: rebuild-data-provider
	@if [ -z "$(ARGS)" ]; then \
		echo "Error: Missing required arguments"; \
		echo "Usage: make start-data-provider ARGS=\"-c <config-file-path> --verbose\""; \
		echo "Example: make start-data-provider ARGS=\"-c ./configs/data_provider_config.json --verbose\""; \
		exit 1; \
	fi
	@echo "Starting data provider with arguments: $(ARGS)"
	@data-provider start $(ARGS)
