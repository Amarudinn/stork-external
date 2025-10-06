# Quick safety check for GitHub upload
Write-Host "🔍 Quick Safety Check for GitHub Upload" -ForegroundColor Green

$issues = 0

# Check if .env exists and is tracked
if (Test-Path ".env") {
    $tracked = git ls-files ".env" 2>$null
    if ($tracked) {
        Write-Host "❌ .env file is tracked - this contains secrets!" -ForegroundColor Red
        $issues++
    } else {
        Write-Host "✅ .env file exists but is properly ignored" -ForegroundColor Green
    }
}

# Check configs directory
if (Test-Path "configs") {
    $configFiles = Get-ChildItem "configs" -File | Where-Object { $_.Name -notmatch "example" -and $_.Name -ne ".gitkeep" }
    if ($configFiles.Count -gt 0) {
        Write-Host "⚠️  Found $($configFiles.Count) non-example config files:" -ForegroundColor Yellow
        foreach ($file in $configFiles) {
            $tracked = git ls-files "configs/$($file.Name)" 2>$null
            if ($tracked) {
                Write-Host "  ❌ configs/$($file.Name) is tracked" -ForegroundColor Red
                $issues++
            } else {
                Write-Host "  ✅ configs/$($file.Name) is ignored" -ForegroundColor Green
            }
        }
    }
}

# Check for build directories
$buildDirs = @(".lib", ".bin", "target")
foreach ($dir in $buildDirs) {
    if (Test-Path $dir) {
        $tracked = git ls-files $dir 2>$null
        if ($tracked) {
            Write-Host "❌ Build directory '$dir' is tracked" -ForegroundColor Red
            $issues++
        } else {
            Write-Host "✅ Build directory '$dir' is properly ignored" -ForegroundColor Green
        }
    }
}

Write-Host "`n📊 Summary:" -ForegroundColor Yellow
if ($issues -eq 0) {
    Write-Host "🎉 All checks passed! Safe to upload to GitHub." -ForegroundColor Green
} else {
    Write-Host "❌ Found $issues issue(s). Fix before uploading!" -ForegroundColor Red
    Write-Host "`nTo fix tracked files:" -ForegroundColor Yellow
    Write-Host "1. git rm --cached [filename]" -ForegroundColor White
    Write-Host "2. git commit -m 'Remove sensitive files from tracking'" -ForegroundColor White
}

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "git status    # Check what will be committed" -ForegroundColor White
Write-Host "git add .     # Stage safe files" -ForegroundColor White
Write-Host "git commit    # Commit changes" -ForegroundColor White
