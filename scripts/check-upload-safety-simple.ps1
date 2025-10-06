# Simple safety check script for GitHub upload
param([switch]$Verbose)

Write-Host "🔍 Checking upload safety for GitHub..." -ForegroundColor Green

$errors = @()
$warnings = @()

# Check for dangerous directories
$dangerousDirs = @(".lib", ".bin", "target", "node_modules")
foreach ($dir in $dangerousDirs) {
    if (Test-Path $dir) {
        $trackedFiles = git ls-files $dir 2>$null
        if ($trackedFiles) {
            $errors += "❌ Directory '$dir' contains tracked files but should be ignored"
        } elseif ($Verbose) {
            Write-Host "✅ Directory '$dir' exists but is properly ignored" -ForegroundColor Green
        }
    }
}

# Check for sensitive files
$sensitivePatterns = @("*.key", "*.pem", "*.secret", ".env")
foreach ($pattern in $sensitivePatterns) {
    $files = Get-ChildItem $pattern -Recurse -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        if ($file.Name -notmatch "\.example\.") {
            $relativePath = $file.FullName.Replace("$PWD\", "").Replace("\", "/")
            $trackedFiles = git ls-files $relativePath 2>$null
            if ($trackedFiles) {
                $errors += "❌ Sensitive file '$relativePath' is tracked by git"
            } elseif ($Verbose) {
                Write-Host "✅ Sensitive file '$relativePath' exists but is properly ignored" -ForegroundColor Green
            }
        }
    }
}

# Check configs directory
if (Test-Path "configs") {
    $configFiles = Get-ChildItem "configs/*" -File | Where-Object { $_.Name -notmatch "\.example\." -and $_.Name -ne ".gitkeep" }
    foreach ($file in $configFiles) {
        $relativePath = $file.FullName.Replace("$PWD\", "").Replace("\", "/")
        $trackedFiles = git ls-files $relativePath 2>$null
        if ($trackedFiles) {
            $errors += "❌ Configuration file '$relativePath' is tracked by git"
        } elseif ($Verbose) {
            Write-Host "✅ Configuration file '$relativePath' exists but is properly ignored" -ForegroundColor Green
        }
    }
}

# Results
Write-Host "`n📊 RESULTS:" -ForegroundColor Yellow

if ($errors.Count -eq 0) {
    Write-Host "🎉 All checks passed! Repository is safe to upload to GitHub." -ForegroundColor Green
} else {
    Write-Host "`n❌ ERRORS (must fix before upload):" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  $error" -ForegroundColor Red
    }
    
    Write-Host "`n🔧 To fix:" -ForegroundColor Yellow
    Write-Host "1. Review and update .gitignore" -ForegroundColor White
    Write-Host "2. Run: git rm --cached [file] (for tracked files)" -ForegroundColor White
    Write-Host "3. Run: git add .gitignore" -ForegroundColor White
    Write-Host "4. Run: git commit -m 'Update gitignore'" -ForegroundColor White
}

Write-Host "`n📋 Quick commands:" -ForegroundColor Cyan
Write-Host "git status                    # See what will be committed" -ForegroundColor White
Write-Host "git diff --cached            # Review staged changes" -ForegroundColor White
Write-Host "git ls-files                 # List all tracked files" -ForegroundColor White

exit $errors.Count
