# Stork External Setup Script for Windows
# This script helps set up the development environment on Windows

Write-Host "Setting up Stork External development environment..." -ForegroundColor Green

# Check if Go is installed
try {
    $goVersion = go version
    Write-Host "✓ Go is installed: $goVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Go is not installed. Please install Go 1.24.3 or later from https://golang.org/dl/" -ForegroundColor Red
    exit 1
}

# Check if Rust is installed
try {
    $rustVersion = rustc --version
    Write-Host "✓ Rust is installed: $rustVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Rust is not installed. Please install Rust from https://rustup.rs/" -ForegroundColor Red
    exit 1
}

# Check if build tools are available
try {
    $gccVersion = gcc --version | Select-Object -First 1
    Write-Host "✓ GCC is available: $gccVersion" -ForegroundColor Green
} catch {
    Write-Host "⚠ GCC not found. You may need to install MinGW-w64 or Visual Studio Build Tools" -ForegroundColor Yellow
    Write-Host "  Download from: https://www.mingw-w64.org/ or https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022" -ForegroundColor Yellow
}

# Create necessary directories
Write-Host "Creating necessary directories..." -ForegroundColor Blue
New-Item -ItemType Directory -Force -Path ".lib" | Out-Null
New-Item -ItemType Directory -Force -Path ".bin" | Out-Null
New-Item -ItemType Directory -Force -Path "configs" | Out-Null

# Copy example configurations if they don't exist
Write-Host "Setting up configuration files..." -ForegroundColor Blue
$configFiles = @(
    "data_provider_config",
    "pull_config", 
    "keys",
    "asset-config",
    "private-key"
)

foreach ($config in $configFiles) {
    $exampleFile = "configs/$config.example.*"
    $targetFile = "configs/$config.*"
    
    if (!(Test-Path $targetFile)) {
        $examplePath = Get-ChildItem $exampleFile -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($examplePath) {
            $extension = $examplePath.Extension
            $newName = "configs/$config$extension"
            Copy-Item $examplePath.FullName $newName
            Write-Host "  ✓ Created $newName from example" -ForegroundColor Green
        }
    }
}

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Edit configuration files in the configs/ directory" -ForegroundColor White
Write-Host "2. Run 'make rust' to build Rust dependencies" -ForegroundColor White
Write-Host "3. Run 'make install' to build and install Go binaries" -ForegroundColor White
Write-Host "4. Run 'make help' to see available commands" -ForegroundColor White

Write-Host "`nSetup completed!" -ForegroundColor Green
