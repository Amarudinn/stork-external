# GitHub Upload Guide

Panduan ini menjelaskan file mana yang perlu dan tidak perlu diupload ke GitHub repository.

## ✅ FILES TO UPLOAD (Wajib Upload)

### Core Project Files
- `README.md` - Dokumentasi utama proyek
- `DEVELOPMENT.md` - Panduan development
- `go.mod` - Go module dependencies
- `go.sum` - Go module checksums
- `Cargo.toml` - Rust workspace configuration
- `rust-toolchain.toml` - Rust toolchain specification
- `Makefile` - Build automation
- `version.txt` - Version information

### Configuration Templates (SAFE - No Secrets)
- `configs/*.example.*` - Template konfigurasi (AMAN)
- `.env.example` - Template environment variables (AMAN)
- `.gitignore` - Git ignore rules
- `.dockerignore` - Docker ignore rules

### Build & Development Scripts
- `mk/` - Makefile includes
- `scripts/setup-windows.ps1` - Windows setup script
- `scripts/setup-unix.sh` - Unix setup script  
- `scripts/build-windows.ps1` - Windows build script
- `docker/` - Docker configuration files
- `docker-compose.yml` - Docker compose configuration

### Source Code
- `apps/` - Application source code
- `shared/` - Shared libraries
- `chains/` - Smart contracts (jika ada)
- `utils/` - Utility tools

### Code Quality & CI/CD
- `.golangci.yml` - Go linting configuration
- `.linkspector.yml` - Link checking configuration (jika ada)
- `.mockery.yaml` - Mock generation config (jika ada)
- `requirements.txt` - Python dependencies (jika diperlukan)

## ❌ FILES NOT TO UPLOAD (Jangan Upload)

### Sensitive Configuration Files
- `configs/*.json` (kecuali *.example.json)
- `configs/*.yaml` (kecuali *.example.yaml)  
- `configs/*.yml` (kecuali *.example.yml)
- `configs/*.secret`
- `.env` - Environment variables dengan data sensitif
- `.env.local` - Local environment overrides

### Build Artifacts
- `.lib/` - Compiled libraries
- `.bin/` - Compiled binaries
- `target/` - Rust build artifacts
- `node_modules/` - Node.js dependencies (jika ada)

### IDE & System Files
- `.DS_Store` - macOS system files
- `.idea/` - IntelliJ IDEA files
- `*.iml` - IntelliJ module files
- `.vscode/` - VS Code settings (opsional, bisa diupload jika untuk tim)

### Temporary & Cache Files
- `*.tmp`
- `*.log`
- `*.cache`
- `debug/`

## 🔒 SECURITY CHECKLIST

Sebelum upload, pastikan TIDAK ADA file yang mengandung:

### ❌ NEVER UPLOAD THESE:
- Private keys (`private-key.secret`, `*.pem`, `*.key`)
- API keys dan tokens
- Database credentials
- Wallet addresses atau mnemonic phrases
- Production configuration dengan data sensitif

### ✅ SAFE TO UPLOAD:
- Template files dengan placeholder values
- Example configurations dengan dummy data
- Documentation dan guides
- Source code tanpa hardcoded secrets

## 📋 PRE-UPLOAD CHECKLIST

Sebelum `git push`, jalankan checklist ini:

1. **Check .gitignore**
   ```bash
   git status
   # Pastikan tidak ada file sensitif yang akan dicommit
   ```

2. **Scan for secrets**
   ```bash
   # Cari potential secrets
   grep -r "api_key\|private_key\|password\|secret" configs/ --exclude="*.example.*"
   ```

3. **Verify example files**
   ```bash
   # Pastikan example files tidak mengandung data real
   cat configs/*.example.*
   cat .env.example
   ```

4. **Test build dari clean state**
   ```bash
   # Clone fresh dan test build
   git clone <your-repo> test-build
   cd test-build
   make setup
   make build-all
   ```

## 🚀 RECOMMENDED UPLOAD WORKFLOW

1. **Prepare repository**
   ```bash
   # Add all safe files
   git add README.md DEVELOPMENT.md
   git add Makefile go.mod go.sum Cargo.toml
   git add mk/ scripts/ docker/
   git add apps/ shared/ utils/
   git add configs/*.example.*
   git add .env.example .gitignore .dockerignore
   git add .golangci.yml rust-toolchain.toml
   ```

2. **Verify what will be committed**
   ```bash
   git status
   git diff --cached
   ```

3. **Commit and push**
   ```bash
   git commit -m "feat: add cross-platform build support and configuration templates"
   git push origin main
   ```

## 📝 NOTES

- File `configs/.gitkeep` bisa diupload untuk menjaga struktur direktori
- Jika ada file khusus tim development (seperti `.vscode/settings.json`), diskusikan dengan tim
- Selalu review PR sebelum merge untuk memastikan tidak ada secrets yang tercommit
- Gunakan GitHub secrets untuk CI/CD environment variables

## 🔄 MAINTENANCE

Secara berkala:
1. Review dan update `.gitignore`
2. Audit repository untuk potential secrets
3. Update example configurations sesuai perubahan
4. Pastikan documentation tetap up-to-date
