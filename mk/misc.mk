LIB_DIR ?= $(CURDIR)/.lib


# Detect architecture and platform for wasmvm
ifeq ($(OS),Windows_NT)
    ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
        WASMVM_ARCH := x86_64
    else ifeq ($(PROCESSOR_ARCHITECTURE),ARM64)
        WASMVM_ARCH := aarch64
    else
        WASMVM_ARCH := x86_64
    endif
    WASMVM_LIB_NAME := libwasmvm.$(WASMVM_ARCH).dll
else
    WASMVM_ARCH := $(shell uname -m | sed 's/x86_64/x86_64/;s/aarch64/aarch64/')
    WASMVM_LIB_NAME := libwasmvm.$(WASMVM_ARCH).so
endif
WASMVM_LIB_DEST := $(LIB_DIR)/$(WASMVM_LIB_NAME)

$(WASMVM_LIB_DEST):
	@echo "Installing CosmWasm libraries..."
	@curl -L https://github.com/CosmWasm/wasmvm/releases/download/v2.2.1/$(WASMVM_LIB_NAME) -o $(WASMVM_LIB_DEST)
	@echo "Successfully installed CosmWasm libraries to $(WASMVM_LIB_DEST)"

wasmvm: $(WASMVM_LIB_DEST)

clean-misc:
	@echo "Cleaning CosmWasm libraries..."
	@rm -f $(WASMVM_LIB_DEST)
	@echo "Successfully cleaned CosmWasm libraries"
