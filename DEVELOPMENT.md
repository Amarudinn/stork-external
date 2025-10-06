# Development Guide

This guide provides detailed instructions for setting up and developing the Stork External project.

## Prerequisites

### Required Software

- **Go 1.24.3+**: [Download from golang.org](https://golang.org/dl/)
- **Rust 1.88.0+**: [Install from rustup.rs](https://rustup.rs/)
- **Git**: For version control

### Build Tools

#### Windows
- **Visual Studio Build Tools** or **MinGW-w64**
  - Visual Studio Build Tools: [Download here](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
  - MinGW-w64: [Download here](https://www.mingw-w64.org/)
- **PowerShell 5.0+** (usually pre-installed)

#### Linux
```bash
# Ubuntu/Debian
sudo apt-get install build-essential pkg-config libssl-dev

# CentOS/RHEL/Fedora
sudo yum groupinstall "Development Tools"
sudo yum install pkg-config openssl-devel
```

#### macOS
```bash
xcode-select --install
```

## Quick Setup

### Automated Setup
```bash
# Run the setup script for your platform
make setup
```

### Manual Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Stork-Oracle/stork-external.git
   cd stork-external
   ```

2. **Create configuration files:**
   ```bash
   # Copy example configurations
   cp configs/data_provider_config.example.json configs/data_provider_config.json
   cp configs/asset-config.example.yaml configs/asset-config.yaml
   cp configs/pull_config.example.json configs/pull_config.json
   cp configs/keys.example.json configs/keys.json
   cp .env.example .env
   ```

3. **Edit configuration files with your settings**

4. **Build the project:**
   ```bash
   # Cross-platform build
   make build-all
   
   # Or step by step
   make rust    # Build Rust components
   make install # Build Go components
   ```

## Development Workflow

### Building Components

#### Build Everything
```bash
make build-all
```

#### Build Individual Components
```bash
# Build Rust FFI libraries
make rust

# Build specific Go applications
make chain_pusher
make publisher_agent
make data_provider
```

#### Windows-Specific Build
```powershell
# Using PowerShell script directly
.\scripts\build-windows.ps1

# With parameters
.\scripts\build-windows.ps1 -Clean -Target chain_pusher
```

### Running Applications

#### Data Provider
```bash
# Using make
make start-data-provider ARGS="-c ./configs/data_provider_config.json --verbose"

# Direct execution
./bin/data_provider start -c ./configs/data_provider_config.json --verbose
```

#### Publisher Agent
```bash
./bin/publisher_agent start -c ./configs/pull_config.json -k ./configs/keys.json
```

#### Chain Pusher
```bash
# EVM
./bin/chain_pusher evm -w wss://api.jp.stork-oracle.network -a your-api-key -c https://your-rpc-url

# Solana
./bin/chain_pusher solana -w wss://api.jp.stork-oracle.network -a your-api-key -r https://api.mainnet-beta.solana.com

# Fuel
./bin/chain_pusher fuel -w wss://api.jp.stork-oracle.network -a your-api-key -r https://mainnet.fuel.network/v1/graphql
```

### Testing

#### Run All Tests
```bash
make test
```

#### Run Integration Tests
```bash
make integration-test
```

#### Run Specific Tests
```bash
go test -v ./apps/data_provider/...
go test -v ./apps/chain_pusher/...
```

### Code Quality

#### Linting
```bash
make lint-go      # Go linting
make lint-rust    # Rust linting
make lint-links   # Check for broken links
```

#### Formatting
```bash
make format-go    # Format Go code
make format-rust  # Format Rust code
```

#### Generate Mocks
```bash
make mocks
```

## Docker Development

### Using Docker Compose

1. **Setup environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

2. **Run services:**
   ```bash
   # Run all services
   docker-compose --profile services up

   # Run specific service
   docker-compose up data-provider
   ```

3. **Integration testing:**
   ```bash
   docker-compose --profile integration up
   ```

### Building Docker Images

```bash
# Build specific service
docker build -f docker/images/Dockerfile --build-arg SERVICE=data_provider -t stork-data-provider .

# Build EVM contract image
docker build -f docker/images/evm.Dockerfile -t stork-evm-contract .
```

## Troubleshooting

### Common Issues

#### CGO Build Errors
- **Windows**: Ensure Visual Studio Build Tools or MinGW-w64 is installed
- **Linux**: Install `build-essential` and `pkg-config`
- **macOS**: Run `xcode-select --install`

#### Missing Rust Libraries
```bash
# Rebuild Rust components
make clean-rust
make rust
```

#### Go Module Issues
```bash
go mod tidy
go mod download
```

#### Permission Issues (Unix)
```bash
chmod +x scripts/setup-unix.sh
chmod +x scripts/build-unix.sh
```

### Platform-Specific Notes

#### Windows
- Use PowerShell as Administrator for setup
- Ensure PATH includes Go, Rust, and build tools
- Use forward slashes or escaped backslashes in paths

#### Linux
- Install development packages for your distribution
- Ensure `LD_LIBRARY_PATH` includes `.lib` directory

#### macOS
- Install Xcode command line tools
- Use Homebrew for additional dependencies if needed

## Contributing

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Run tests and linting**
5. **Submit a pull request**

### Code Style

- Follow Go conventions and use `gofmt`
- Follow Rust conventions and use `rustfmt`
- Write tests for new functionality
- Update documentation as needed

## Environment Variables

See `.env.example` for a complete list of environment variables and their descriptions.

## Configuration Files

All configuration files should be placed in the `configs/` directory:

- `data_provider_config.json`: Data provider configuration
- `pull_config.json`: Publisher agent configuration
- `keys.json`: Cryptographic keys
- `asset-config.yaml`: Asset configuration for chain pusher
- `private-key.secret`: Private key file

**Important**: Never commit actual configuration files with sensitive data to version control.
