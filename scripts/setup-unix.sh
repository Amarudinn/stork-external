#!/bin/bash
# Stork External Setup Script for Unix-like systems (Linux/macOS)
# This script helps set up the development environment

set -e

echo "Setting up Stork External development environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Go is installed
if command -v go &> /dev/null; then
    echo -e "${GREEN}✓ Go is installed: $(go version)${NC}"
else
    echo -e "${RED}✗ Go is not installed. Please install Go 1.24.3 or later from https://golang.org/dl/${NC}"
    exit 1
fi

# Check if Rust is installed
if command -v rustc &> /dev/null; then
    echo -e "${GREEN}✓ Rust is installed: $(rustc --version)${NC}"
else
    echo -e "${RED}✗ Rust is not installed. Please install Rust from https://rustup.rs/${NC}"
    exit 1
fi

# Check if build tools are available
if command -v gcc &> /dev/null || command -v clang &> /dev/null; then
    if command -v gcc &> /dev/null; then
        echo -e "${GREEN}✓ GCC is available: $(gcc --version | head -n1)${NC}"
    else
        echo -e "${GREEN}✓ Clang is available: $(clang --version | head -n1)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Neither GCC nor Clang found. Please install build tools${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${YELLOW}  Run: xcode-select --install${NC}"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -e "${YELLOW}  Run: sudo apt-get install build-essential (Ubuntu/Debian)${NC}"
        echo -e "${YELLOW}  Or:  sudo yum groupinstall 'Development Tools' (CentOS/RHEL)${NC}"
    fi
fi

# Create necessary directories
echo -e "${BLUE}Creating necessary directories...${NC}"
mkdir -p .lib .bin configs

# Copy example configurations if they don't exist
echo -e "${BLUE}Setting up configuration files...${NC}"
for config in data_provider_config pull_config keys asset-config private-key; do
    example_file=$(find configs/ -name "$config.example.*" 2>/dev/null | head -n1)
    if [[ -n "$example_file" ]]; then
        extension="${example_file##*.}"
        target_file="configs/$config.$extension"
        if [[ ! -f "$target_file" ]]; then
            cp "$example_file" "$target_file"
            echo -e "${GREEN}  ✓ Created $target_file from example${NC}"
        fi
    fi
done

echo -e "${YELLOW}\nNext steps:${NC}"
echo -e "${NC}1. Edit configuration files in the configs/ directory${NC}"
echo -e "${NC}2. Run 'make rust' to build Rust dependencies${NC}"
echo -e "${NC}3. Run 'make install' to build and install Go binaries${NC}"
echo -e "${NC}4. Run 'make help' to see available commands${NC}"

echo -e "${GREEN}\nSetup completed!${NC}"
