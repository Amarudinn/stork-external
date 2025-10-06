![stork Logo](public/stork-logo.png "Title")

<p align="center"><b>Your Data, Your Protocol</b></p>

## Stork External

Stork leverages cryptographic primitives used in blockchain technologies to securely and reliably deliver accurate, ultra-low latency, and chain-agnostic data feeds.

This repository contains various components utilized by data publishers and subscribers to leverage Stork's technology.

## Quick Start

### Prerequisites

- Go 1.24.3 or later
- Rust 1.88.0 or later
- Docker (optional, for containerized deployment)
- Build tools (gcc/clang for CGO)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Stork-Oracle/stork-external.git
   cd stork-external
   ```

2. **Build Rust dependencies:**
   ```bash
   make rust
   ```

3. **Install Go binaries:**
   ```bash
   make install
   ```

4. **Setup configuration files:**
   ```bash
   # Copy example configurations
   cp configs/data_provider_config.example.json configs/data_provider_config.json
   cp configs/asset-config.example.yaml configs/asset-config.yaml
   # Edit the configuration files with your settings
   ```

### Usage

#### Data Provider
```bash
# Start data provider
make start-data-provider ARGS="-c ./configs/data_provider_config.json --verbose"
```

#### Chain Pusher
```bash
# Run chain pusher for EVM
chain_pusher evm -w wss://api.jp.stork-oracle.network -a your-api-key -c https://your-rpc-url
```

#### Publisher Agent
```bash
# Run publisher agent
publisher_agent start -c ./configs/pull_config.json -k ./configs/keys.json
```

## Components

#### [Apps](apps)

Tooling used to interface with Stork's services and on-chain contracts.

#### [Contracts](chains)

All contracts developed by Stork are managed in this directory.

## Configuration

All configuration files should be placed in the `configs/` directory. Example files are provided with `.example` suffix.

**Important:** Never commit actual configuration files containing sensitive information like private keys to version control.
