# 🚀 SAFE TO UPLOAD - Quick Reference

File-file ini **AMAN** untuk diupload ke GitHub:

## ✅ CORE FILES
```
README.md
DEVELOPMENT.md
GITHUB_UPLOAD_GUIDE.md
SAFE_TO_UPLOAD.md
go.mod
go.sum
Cargo.toml
rust-toolchain.toml
Makefile
version.txt
requirements.txt
```

## ✅ CONFIGURATION TEMPLATES (No Secrets)
```
configs/*.example.*
.env.example
.gitignore
.dockerignore
```

## ✅ BUILD & SCRIPTS
```
mk/
scripts/setup-windows.ps1
scripts/setup-unix.sh
scripts/build-windows.ps1
scripts/check-upload-safety.ps1
scripts/check-upload-safety.sh
docker/
docker-compose.yml
```

## ✅ SOURCE CODE
```
apps/
shared/
chains/
utils/
```

## ✅ CODE QUALITY
```
.golangci.yml
.linkspector.yml
.mockery.yaml
```

---

# ❌ NEVER UPLOAD

## 🔒 SENSITIVE FILES
```
configs/*.json (except *.example.json)
configs/*.yaml (except *.example.yaml)
configs/*.secret
.env
.env.local
private-key.*
*.pem
*.key
```

## 🗂️ BUILD ARTIFACTS
```
.lib/
.bin/
target/
node_modules/
```

## 💻 IDE FILES
```
.DS_Store
.idea/
*.iml
```

---

# 🛡️ QUICK SAFETY CHECK

Before uploading, run:

**Windows:**
```powershell
.\scripts\check-upload-safety.ps1 -Verbose
```

**Unix/Linux/macOS:**
```bash
chmod +x scripts/check-upload-safety.sh
./scripts/check-upload-safety.sh --verbose
```

**Git Status Check:**
```bash
git status
git diff --cached
```

---

# 📋 UPLOAD CHECKLIST

- [ ] Ran safety check script
- [ ] No sensitive files in `git status`
- [ ] All secrets are in `.example` files only
- [ ] `.gitignore` is up to date
- [ ] Documentation is current
- [ ] Build works from clean clone

**Ready to upload!** 🎉
