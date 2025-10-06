# Final safety check before GitHub upload
Write-Host "=== GITHUB UPLOAD SAFETY CHECK ===" -ForegroundColor Green
Write-Host ""

$issues = 0

# Check 1: .env file
Write-Host "1. Checking .env file..." -ForegroundColor Blue
if (Test-Path ".env") {
    $tracked = git ls-files ".env" 2>$null
    if ($tracked) {
        Write-Host "   ❌ .env file is tracked (contains secrets!)" -ForegroundColor Red
        $issues++
    } else {
        Write-Host "   ✅ .env exists but properly ignored" -ForegroundColor Green
    }
} else {
    Write-Host "   ✅ No .env file found" -ForegroundColor Green
}

# Check 2: Config files
Write-Host "2. Checking config files..." -ForegroundColor Blue
if (Test-Path "configs") {
    $badConfigs = Get-ChildItem "configs" -File | Where-Object { 
        $_.Name -notmatch "example" -and $_.Name -ne ".gitkeep" 
    }
    
    if ($badConfigs) {
        foreach ($config in $badConfigs) {
            $tracked = git ls-files "configs/$($config.Name)" 2>$null
            if ($tracked) {
                Write-Host "   ❌ configs/$($config.Name) is tracked" -ForegroundColor Red
                $issues++
            } else {
                Write-Host "   ✅ configs/$($config.Name) exists but ignored" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "   ✅ Only example configs found" -ForegroundColor Green
    }
} else {
    Write-Host "   ✅ No configs directory" -ForegroundColor Green
}

# Check 3: Build directories
Write-Host "3. Checking build directories..." -ForegroundColor Blue
$buildDirs = @(".lib", ".bin", "target")
foreach ($dir in $buildDirs) {
    if (Test-Path $dir) {
        $tracked = git ls-files $dir 2>$null
        if ($tracked) {
            Write-Host "   ❌ $dir is tracked" -ForegroundColor Red
            $issues++
        } else {
            Write-Host "   ✅ $dir exists but ignored" -ForegroundColor Green
        }
    } else {
        Write-Host "   ✅ $dir not found" -ForegroundColor Green
    }
}

# Check 4: Sensitive file patterns
Write-Host "4. Checking for sensitive files..." -ForegroundColor Blue
$sensitiveFiles = @("*.key", "*.pem", "*.secret", "private-key*")
$foundSensitive = $false

foreach ($pattern in $sensitiveFiles) {
    $files = Get-ChildItem $pattern -Recurse -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        if ($file.Name -notmatch "example") {
            $relativePath = $file.FullName.Replace("$PWD\", "")
            $tracked = git ls-files $relativePath 2>$null
            if ($tracked) {
                Write-Host "   ❌ Sensitive file tracked: $relativePath" -ForegroundColor Red
                $issues++
                $foundSensitive = $true
            }
        }
    }
}

if (-not $foundSensitive) {
    Write-Host "   ✅ No sensitive files tracked" -ForegroundColor Green
}

# Summary
Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Yellow
if ($issues -eq 0) {
    Write-Host "🎉 ALL CHECKS PASSED! Safe to upload to GitHub." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. git add ." -ForegroundColor White
    Write-Host "2. git commit -m 'Your commit message'" -ForegroundColor White
    Write-Host "3. git push origin main" -ForegroundColor White
} else {
    Write-Host "❌ Found $issues issue(s). Fix before uploading!" -ForegroundColor Red
    Write-Host ""
    Write-Host "To fix:" -ForegroundColor Yellow
    Write-Host "1. git rm --cached [filename]  # Remove from tracking" -ForegroundColor White
    Write-Host "2. Add to .gitignore if needed" -ForegroundColor White
    Write-Host "3. git commit -m 'Remove sensitive files'" -ForegroundColor White
}

Write-Host ""
Write-Host "Quick check commands:" -ForegroundColor Cyan
Write-Host "git status        # See what will be committed" -ForegroundColor White
Write-Host "git ls-files      # List all tracked files" -ForegroundColor White
