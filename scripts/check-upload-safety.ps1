# Script untuk memeriksa keamanan file sebelum upload ke GitHub
# Mendeteksi potential secrets dan file sensitif

param(
    [switch]$Verbose,
    [switch]$Fix
)

Write-Host "🔍 Checking upload safety for GitHub..." -ForegroundColor Green

$errors = @()
$warnings = @()

# Patterns yang menunjukkan potential secrets
$secretPatterns = @(
    "private[_-]?key\s*[:=]\s*['`""]?[0-9a-fA-F]{40,}",
    "api[_-]?key\s*[:=]\s*['`""]?[a-zA-Z0-9]{20,}",
    "secret\s*[:=]\s*['`""]?[a-zA-Z0-9]{20,}",
    "password\s*[:=]\s*['`""]?[^\s]{8,}",
    "token\s*[:=]\s*['`""]?[a-zA-Z0-9]{20,}",
    "0x[0-9a-fA-F]{40,}",
    "[0-9a-fA-F]{64}"
)

# File extensions yang tidak boleh diupload
$dangerousExtensions = @(".key", ".pem", ".p12", ".pfx", ".secret")

# Directories yang tidak boleh diupload
$dangerousDirectories = @(".lib", ".bin", "target", "node_modules")

Write-Host "`n📁 Checking directory structure..." -ForegroundColor Blue

# Check for dangerous directories
foreach ($dir in $dangerousDirectories) {
    if (Test-Path $dir) {
        if (git ls-files $dir 2>$null) {
            $errors += "❌ Directory '$dir' is tracked by git but should be ignored"
        } else {
            Write-Host "✅ Directory '$dir' exists but is properly ignored" -ForegroundColor Green
        }
    }
}

Write-Host "`n🔍 Scanning for potential secrets..." -ForegroundColor Blue

# Get all tracked files
$trackedFiles = git ls-files 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Not in a git repository or git not available" -ForegroundColor Yellow
    $trackedFiles = Get-ChildItem -Recurse -File | Where-Object { 
        $_.FullName -notmatch "\\.(git|lib|bin|target)\\|node_modules" 
    } | ForEach-Object { $_.FullName.Replace("$PWD\", "").Replace("\", "/") }
}

foreach ($file in $trackedFiles) {
    if (!(Test-Path $file)) { continue }
    
    $extension = [System.IO.Path]::GetExtension($file).ToLower()
    
    # Check dangerous extensions
    if ($extension -in $dangerousExtensions) {
        $errors += "❌ File '$file' has dangerous extension '$extension'"
        continue
    }
    
    # Skip binary files and large files
    $fileInfo = Get-Item $file
    if ($fileInfo.Length -gt 1MB) {
        $warnings += "⚠️  Large file '$file' ($(($fileInfo.Length/1MB).ToString('F1'))MB)"
        continue
    }
    
    # Check for secrets in text files
    if ($extension -in @(".txt", ".json", ".yaml", ".yml", ".toml", ".env", ".md", ".go", ".rs", ".js", ".ts", ".py", ".sh", ".ps1", ".bat", ".cmd", "")) {
        try {
            $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
            if ($content) {
                foreach ($pattern in $secretPatterns) {
                    if ($content -match $pattern) {
                        # Skip if it's an example file
                        if ($file -match "\.example\." -or $file -match "example" -or $file -match "sample") {
                            if ($Verbose) {
                                Write-Host "ℹ️  Pattern match in example file '$file' (likely safe)" -ForegroundColor Cyan
                            }
                        } else {
                            $errors += "❌ Potential secret found in '$file': pattern '$pattern'"
                        }
                    }
                }
            }
        } catch {
            $warnings += "⚠️  Could not read file '$file': $($_.Exception.Message)"
        }
    }
}

Write-Host "`n📋 Checking configuration files..." -ForegroundColor Blue

# Check if actual config files exist (should not be uploaded)
$configFiles = @(
    "configs/*.json",
    "configs/*.yaml", 
    "configs/*.yml",
    "configs/*.secret",
    ".env"
)

foreach ($pattern in $configFiles) {
    $files = Get-ChildItem $pattern -ErrorAction SilentlyContinue | Where-Object { 
        $_.Name -notmatch "\.example\." 
    }
    foreach ($file in $files) {
        if (git ls-files $file.FullName.Replace("$PWD\", "").Replace("\", "/") 2>$null) {
            $errors += "❌ Configuration file '$($file.Name)' is tracked by git"
        } else {
            if ($Verbose) {
                Write-Host "✅ Configuration file '$($file.Name)' exists but is properly ignored" -ForegroundColor Green
            }
        }
    }
}

Write-Host "`n📊 RESULTS:" -ForegroundColor Yellow

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "🎉 All checks passed! Repository is safe to upload to GitHub." -ForegroundColor Green
} else {
    if ($errors.Count -gt 0) {
        Write-Host "`n❌ ERRORS (must fix before upload):" -ForegroundColor Red
        foreach ($error in $errors) {
            Write-Host "  $error" -ForegroundColor Red
        }
    }
    
    if ($warnings.Count -gt 0) {
        Write-Host "`n⚠️  WARNINGS (review recommended):" -ForegroundColor Yellow
        foreach ($warning in $warnings) {
            Write-Host "  $warning" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n🔧 RECOMMENDATIONS:" -ForegroundColor Cyan
Write-Host "1. Review .gitignore to ensure sensitive files are excluded" -ForegroundColor White
Write-Host "2. Use 'git status' to see what will be committed" -ForegroundColor White
Write-Host "3. Use 'git diff --cached' to review staged changes" -ForegroundColor White
Write-Host "4. Consider using GitHub secrets for sensitive CI/CD variables" -ForegroundColor White

if ($Fix -and $errors.Count -gt 0) {
    Write-Host "`n🔧 Attempting to fix issues..." -ForegroundColor Blue
    
    # Add dangerous files to .gitignore if not already there
    $gitignoreContent = ""
    if (Test-Path ".gitignore") {
        $gitignoreContent = Get-Content ".gitignore" -Raw
    }
    
    $additions = @()
    foreach ($error in $errors) {
        if ($error -match "Directory '(.+)' is tracked") {
            $dir = $matches[1]
            if ($gitignoreContent -notmatch [regex]::Escape($dir)) {
                $additions += $dir + "/"
            }
        }
        elseif ($error -match "File '(.+)' has dangerous extension") {
            $file = $matches[1]
            if ($gitignoreContent -notmatch [regex]::Escape($file)) {
                $additions += $file
            }
        }
    }
    
    if ($additions.Count -gt 0) {
        Add-Content ".gitignore" "`n# Auto-added by safety check"
        foreach ($addition in $additions) {
            Add-Content ".gitignore" $addition
            Write-Host "✅ Added '$addition' to .gitignore" -ForegroundColor Green
        }
        Write-Host "🔄 Run 'git rm --cached <file>' to untrack files that are now ignored" -ForegroundColor Yellow
    }
}

exit $errors.Count
