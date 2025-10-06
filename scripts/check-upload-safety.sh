#!/bin/bash
# Script untuk memeriksa keamanan file sebelum upload ke GitHub
# Mendeteksi potential secrets dan file sensitif

set -e

VERBOSE=false
FIX=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--fix)
            FIX=true
            shift
            ;;
        *)
            echo "Usage: $0 [-v|--verbose] [-f|--fix]"
            exit 1
            ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔍 Checking upload safety for GitHub...${NC}"

errors=()
warnings=()

# Patterns yang menunjukkan potential secrets
secret_patterns=(
    "private[_-]?key\s*[:=]\s*['\`\"]?[0-9a-fA-F]{40,}"
    "api[_-]?key\s*[:=]\s*['\`\"]?[a-zA-Z0-9]{20,}"
    "secret\s*[:=]\s*['\`\"]?[a-zA-Z0-9]{20,}"
    "password\s*[:=]\s*['\`\"]?[^\s]{8,}"
    "token\s*[:=]\s*['\`\"]?[a-zA-Z0-9]{20,}"
    "0x[0-9a-fA-F]{40,}"  # Ethereum addresses/keys
    "[0-9a-fA-F]{64}"     # 64-char hex strings
)

# File extensions yang tidak boleh diupload
dangerous_extensions=(".key" ".pem" ".p12" ".pfx" ".secret")

# Directories yang tidak boleh diupload
dangerous_directories=(".lib" ".bin" "target" "node_modules")

echo -e "\n${BLUE}📁 Checking directory structure...${NC}"

# Check for dangerous directories
for dir in "${dangerous_directories[@]}"; do
    if [[ -d "$dir" ]]; then
        if git ls-files "$dir" >/dev/null 2>&1 && [[ -n $(git ls-files "$dir") ]]; then
            errors+=("❌ Directory '$dir' is tracked by git but should be ignored")
        else
            [[ "$VERBOSE" == true ]] && echo -e "${GREEN}✅ Directory '$dir' exists but is properly ignored${NC}"
        fi
    fi
done

echo -e "\n${BLUE}🔍 Scanning for potential secrets...${NC}"

# Get all tracked files
if git rev-parse --git-dir >/dev/null 2>&1; then
    tracked_files=$(git ls-files)
else
    echo -e "${YELLOW}⚠️  Not in a git repository or git not available${NC}"
    tracked_files=$(find . -type f -not -path "./.git/*" -not -path "./.lib/*" -not -path "./.bin/*" -not -path "./target/*" -not -path "./node_modules/*" | sed 's|^\./||')
fi

while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    [[ ! -f "$file" ]] && continue
    
    extension="${file##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    
    # Check dangerous extensions
    for ext in "${dangerous_extensions[@]}"; do
        if [[ ".$extension" == "$ext" ]]; then
            errors+=("❌ File '$file' has dangerous extension '$ext'")
            continue 2
        fi
    done
    
    # Skip binary files and large files
    if [[ -f "$file" ]]; then
        file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)
        if [[ $file_size -gt 1048576 ]]; then  # 1MB
            size_mb=$(echo "scale=1; $file_size/1048576" | bc 2>/dev/null || echo "large")
            warnings+=("⚠️  Large file '$file' (${size_mb}MB)")
            continue
        fi
    fi
    
    # Check for secrets in text files
    case "$extension" in
        txt|json|yaml|yml|toml|env|md|go|rs|js|ts|py|sh|ps1|bat|cmd|"")
            if [[ -r "$file" ]]; then
                for pattern in "${secret_patterns[@]}"; do
                    if grep -qE "$pattern" "$file" 2>/dev/null; then
                        # Skip if it's an example file
                        if [[ "$file" =~ \.example\. ]] || [[ "$file" =~ example ]] || [[ "$file" =~ sample ]]; then
                            [[ "$VERBOSE" == true ]] && echo -e "${CYAN}ℹ️  Pattern match in example file '$file' (likely safe)${NC}"
                        else
                            errors+=("❌ Potential secret found in '$file': pattern '$pattern'")
                        fi
                    fi
                done
            else
                warnings+=("⚠️  Could not read file '$file'")
            fi
            ;;
    esac
done <<< "$tracked_files"

echo -e "\n${BLUE}📋 Checking configuration files...${NC}"

# Check if actual config files exist (should not be uploaded)
config_patterns=("configs/*.json" "configs/*.yaml" "configs/*.yml" "configs/*.secret" ".env")

for pattern in "${config_patterns[@]}"; do
    for file in $pattern; do
        [[ ! -f "$file" ]] && continue
        [[ "$file" =~ \.example\. ]] && continue
        
        if git ls-files "$file" >/dev/null 2>&1 && [[ -n $(git ls-files "$file") ]]; then
            errors+=("❌ Configuration file '$file' is tracked by git")
        else
            [[ "$VERBOSE" == true ]] && echo -e "${GREEN}✅ Configuration file '$file' exists but is properly ignored${NC}"
        fi
    done
done

echo -e "\n${YELLOW}📊 RESULTS:${NC}"

if [[ ${#errors[@]} -eq 0 && ${#warnings[@]} -eq 0 ]]; then
    echo -e "${GREEN}🎉 All checks passed! Repository is safe to upload to GitHub.${NC}"
else
    if [[ ${#errors[@]} -gt 0 ]]; then
        echo -e "\n${RED}❌ ERRORS (must fix before upload):${NC}"
        for error in "${errors[@]}"; do
            echo -e "  ${RED}$error${NC}"
        done
    fi
    
    if [[ ${#warnings[@]} -gt 0 ]]; then
        echo -e "\n${YELLOW}⚠️  WARNINGS (review recommended):${NC}"
        for warning in "${warnings[@]}"; do
            echo -e "  ${YELLOW}$warning${NC}"
        done
    fi
fi

echo -e "\n${CYAN}🔧 RECOMMENDATIONS:${NC}"
echo -e "${NC}1. Review .gitignore to ensure sensitive files are excluded${NC}"
echo -e "${NC}2. Use 'git status' to see what will be committed${NC}"
echo -e "${NC}3. Use 'git diff --cached' to review staged changes${NC}"
echo -e "${NC}4. Consider using GitHub secrets for sensitive CI/CD variables${NC}"

if [[ "$FIX" == true && ${#errors[@]} -gt 0 ]]; then
    echo -e "\n${BLUE}🔧 Attempting to fix issues...${NC}"
    
    # Add dangerous files to .gitignore if not already there
    gitignore_content=""
    [[ -f ".gitignore" ]] && gitignore_content=$(cat .gitignore)
    
    additions=()
    for error in "${errors[@]}"; do
        if [[ "$error" =~ Directory\ \'([^\']+)\'\ is\ tracked ]]; then
            dir="${BASH_REMATCH[1]}"
            if [[ ! "$gitignore_content" =~ $dir ]]; then
                additions+=("$dir/")
            fi
        elif [[ "$error" =~ File\ \'([^\']+)\'\ has\ dangerous\ extension ]]; then
            file="${BASH_REMATCH[1]}"
            if [[ ! "$gitignore_content" =~ $file ]]; then
                additions+=("$file")
            fi
        fi
    done
    
    if [[ ${#additions[@]} -gt 0 ]]; then
        echo "" >> .gitignore
        echo "# Auto-added by safety check" >> .gitignore
        for addition in "${additions[@]}"; do
            echo "$addition" >> .gitignore
            echo -e "${GREEN}✅ Added '$addition' to .gitignore${NC}"
        done
        echo -e "${YELLOW}🔄 Run 'git rm --cached <file>' to untrack files that are now ignored${NC}"
    fi
fi

exit ${#errors[@]}
