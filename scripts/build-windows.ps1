# Build script for Windows
# This script builds the Stork External project on Windows

param(
    [switch]$Clean,
    [switch]$Verbose,
    [string]$Target = "all"
)

$ErrorActionPreference = "Stop"

Write-Host "Building Stork External on Windows..." -ForegroundColor Green

# Set environment variables for CGO
$env:CGO_ENABLED = "1"
$env:GOOS = "windows"

# Create lib directory if it doesn't exist
if (!(Test-Path ".lib")) {
    New-Item -ItemType Directory -Path ".lib" | Out-Null
    Write-Host "Created .lib directory" -ForegroundColor Blue
}

# Clean if requested
if ($Clean) {
    Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
    if (Test-Path ".lib") {
        Remove-Item -Recurse -Force ".lib\*"
    }
    if (Test-Path ".bin") {
        Remove-Item -Recurse -Force ".bin\*"
    }
    if (Test-Path "target") {
        Remove-Item -Recurse -Force "target"
    }
    go clean -cache -testcache
    cargo clean
}

try {
    # Build Rust components first
    Write-Host "Building Rust components..." -ForegroundColor Blue
    cargo build --release
    
    if ($LASTEXITCODE -ne 0) {
        throw "Rust build failed"
    }
    
    # Copy Rust artifacts to .lib directory
    Write-Host "Copying Rust artifacts..." -ForegroundColor Blue
    
    # Copy libraries
    $rustLibs = @("signer_ffi", "fuel_ffi")
    foreach ($lib in $rustLibs) {
        $srcLib = "target\release\$lib.dll"
        $destLib = ".lib\lib$lib.dll"
        if (Test-Path $srcLib) {
            Copy-Item $srcLib $destLib
            Write-Host "  ✓ Copied $lib.dll" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ $srcLib not found" -ForegroundColor Yellow
        }
    }
    
    # Copy headers
    $headers = @("signer_ffi.h", "fuel_ffi.h")
    foreach ($header in $headers) {
        $srcHeader = "target\include\$header"
        $destHeader = ".lib\$header"
        if (Test-Path $srcHeader) {
            Copy-Item $srcHeader $destHeader
            Write-Host "  ✓ Copied $header" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ $srcHeader not found" -ForegroundColor Yellow
        }
    }
    
    # Set CGO flags
    $env:CGO_LDFLAGS = "-L$PWD\.lib"
    $env:CGO_CFLAGS = "-I$PWD\.lib"
    $env:LD_LIBRARY_PATH = "$PWD\.lib;$env:LD_LIBRARY_PATH"
    
    # Build Go components
    Write-Host "Building Go components..." -ForegroundColor Blue
    
    switch ($Target) {
        "all" {
            $apps = @("chain_pusher", "publisher_agent", "data_provider")
            foreach ($app in $apps) {
                Write-Host "  Building $app..." -ForegroundColor Cyan
                go build -v -o ".bin\$app.exe" ".\apps\$app"
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✓ Built $app.exe" -ForegroundColor Green
                } else {
                    Write-Host "  ✗ Failed to build $app" -ForegroundColor Red
                }
            }
        }
        default {
            Write-Host "  Building $Target..." -ForegroundColor Cyan
            go build -v -o ".bin\$Target.exe" ".\apps\$Target"
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Built $Target.exe" -ForegroundColor Green
            } else {
                throw "Failed to build $Target"
            }
        }
    }
    
    Write-Host "`nBuild completed successfully!" -ForegroundColor Green
    Write-Host "Binaries are available in the .bin directory" -ForegroundColor Blue
    
} catch {
    Write-Host "`nBuild failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
