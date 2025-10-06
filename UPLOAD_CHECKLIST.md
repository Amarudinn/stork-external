# 📋 GitHub Upload Checklist

Gunakan checklist ini sebelum upload ke GitHub:

## ✅ PRE-UPLOAD CHECKS

### 1. Check Git Status
```bash
git status
```
**Pastikan tidak ada file sensitif yang akan di-commit**

### 2. Check Staged Files
```bash
git diff --cached
```
**Review semua perubahan yang akan di-commit**

### 3. Manual File Check
Pastikan file-file ini **TIDAK** ada dalam `git status`:
- [ ] `.env` (bukan `.env.example`)
- [ ] `configs/*.json` (kecuali `*.example.json`)
- [ ] `configs/*.yaml` (kecuali `*.example.yaml`)
- [ ] `configs/*.secret`
- [ ] `private-key.*`
- [ ] `*.key`, `*.pem`
- [ ] `.lib/`, `.bin/`, `target/`

### 4. Check Example Files
Pastikan file example tidak mengandung data real:
- [ ] `configs/*.example.*` - hanya placeholder values
- [ ] `.env.example` - hanya template variables
- [ ] Tidak ada private keys atau API keys real

## ✅ SAFE FILES TO UPLOAD

### Core Files
- [x] `README.md`
- [x] `DEVELOPMENT.md`
- [x] `GITHUB_UPLOAD_GUIDE.md`
- [x] `SAFE_TO_UPLOAD.md`
- [x] `UPLOAD_CHECKLIST.md`
- [x] `go.mod`, `go.sum`
- [x] `Cargo.toml`
- [x] `Makefile`

### Configuration Templates
- [x] `configs/*.example.*`
- [x] `.env.example`
- [x] `.gitignore`
- [x] `.dockerignore`

### Scripts & Build
- [x] `scripts/setup-*.ps1`
- [x] `scripts/setup-*.sh`
- [x] `scripts/build-*.ps1`
- [x] `scripts/quick-safety-check.ps1`
- [x] `mk/`
- [x] `docker/`
- [x] `docker-compose.yml`

### Source Code
- [x] `apps/`
- [x] `shared/`
- [x] `utils/`

### Code Quality
- [x] `.golangci.yml`
- [x] `rust-toolchain.toml`

## 🚀 UPLOAD COMMANDS

### 1. Add Safe Files
```bash
# Add documentation
git add README.md DEVELOPMENT.md *.md

# Add core files
git add go.mod go.sum Cargo.toml Makefile rust-toolchain.toml

# Add configuration templates (safe)
git add configs/*.example.* .env.example

# Add build files
git add .gitignore .dockerignore docker/ mk/ scripts/

# Add source code
git add apps/ shared/ utils/

# Add code quality configs
git add .golangci.yml
```

### 2. Verify Before Commit
```bash
git status
git diff --cached
```

### 3. Commit and Push
```bash
git commit -m "feat: add cross-platform build support and configuration templates

- Add Windows/Unix build scripts and setup
- Add configuration templates with examples
- Update documentation with development guide
- Improve Docker configuration with environment variables
- Add safety checks for sensitive files"

git push origin main
```

## ⚠️ IF YOU ACCIDENTALLY COMMIT SECRETS

### Remove from Git History
```bash
# Remove file from tracking
git rm --cached path/to/sensitive/file

# Add to .gitignore
echo "path/to/sensitive/file" >> .gitignore

# Commit the removal
git commit -m "Remove sensitive file from tracking"

# For files already pushed, you may need to rewrite history
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch path/to/sensitive/file' \
  --prune-empty --tag-name-filter cat -- --all
```

### Rotate Compromised Secrets
If secrets were pushed to GitHub:
1. **Immediately rotate** all exposed keys/tokens
2. **Revoke** old credentials
3. **Update** all systems using those credentials
4. **Consider** making repository private temporarily

## 🎯 FINAL CHECK

Before pushing, ask yourself:
- [ ] Would I be comfortable if this repository was public?
- [ ] Are all secrets in example files only?
- [ ] Can someone clone and build without my personal configs?
- [ ] Is the documentation clear for new contributors?

**If all checks pass, you're ready to upload! 🚀**
