#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Setting up OpenTofu Google Project Module environment...${NC}"

# Create terraform plugin cache directory
PLUGIN_CACHE_DIR="${HOME}/.terraform.d/plugin-cache"
if [[ ! -d "${PLUGIN_CACHE_DIR}" ]]; then
    echo -e "${YELLOW}📁 Creating Terraform plugin cache directory...${NC}"
    mkdir -p "${PLUGIN_CACHE_DIR}"
    echo -e "${GREEN}✅ Created ${PLUGIN_CACHE_DIR}${NC}"
else
    echo -e "${GREEN}✅ Plugin cache directory already exists${NC}"
fi

# Check if required tools are installed
check_tool() {
    local tool=$1
    local install_cmd=$2

    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}✅ $tool is installed${NC}"
        return 0
    else
        echo -e "${RED}❌ $tool is not installed${NC}"
        if [[ -n "$install_cmd" ]]; then
            echo -e "${YELLOW}   Install with: $install_cmd${NC}"
        fi
        return 1
    fi
}

echo -e "\n${BLUE}🔍 Checking required tools...${NC}"

# Required tools
tools_missing=0

check_tool "tofu" "https://opentofu.org/docs/intro/install/" || ((tools_missing++))
check_tool "tflint" "brew install tflint" || ((tools_missing++))
check_tool "terraform-docs" "brew install terraform-docs" || ((tools_missing++))
check_tool "pre-commit" "pip install pre-commit" || ((tools_missing++))
check_tool "direnv" "brew install direnv" || ((tools_missing++))
check_tool "trufflehog" "brew install trufflehog" || ((tools_missing++))

# Optional but recommended tools
echo -e "\n${BLUE}🔍 Checking optional tools...${NC}"
check_tool "tfsec" "brew install tfsec" || echo -e "${YELLOW}   ⚠️  tfsec is optional but recommended for security scanning${NC}"
check_tool "checkov" "pip install checkov" || echo -e "${YELLOW}   ⚠️  checkov is optional for policy scanning${NC}"

# Check Google Cloud authentication
if command -v gcloud &> /dev/null; then
    echo -e "\n${GREEN}✅ gcloud CLI is installed${NC}"
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ gcloud authentication is configured${NC}"
    else
        echo -e "${YELLOW}⚠️  gcloud authentication not configured${NC}"
        echo -e "${YELLOW}   Run: gcloud auth login && gcloud auth application-default login${NC}"
    fi
else
    echo -e "\n${YELLOW}⚠️  gcloud CLI is not installed${NC}"
    echo -e "${YELLOW}   Install with: https://cloud.google.com/sdk/docs/install${NC}"
fi

# Check environment variables
if [[ -z "${GOOGLE_PROJECT:-}" ]]; then
    echo -e "\n${YELLOW}⚠️  GOOGLE_PROJECT environment variable is not set${NC}"
    echo -e "${YELLOW}   This may be required for some operations${NC}"
else
    echo -e "\n${GREEN}✅ GOOGLE_PROJECT is configured${NC}"
fi

# Setup pre-commit hooks
if [[ $tools_missing -eq 0 ]]; then
    echo -e "\n${BLUE}🔗 Installing pre-commit hooks...${NC}"
    if pre-commit install; then
        echo -e "${GREEN}✅ Pre-commit hooks installed${NC}"
    else
        echo -e "${RED}❌ Failed to install pre-commit hooks${NC}"
    fi
else
    echo -e "\n${RED}❌ Cannot install pre-commit hooks - missing required tools${NC}"
fi

# Initialize OpenTofu in examples
echo -e "\n${BLUE}🏗️  Initializing OpenTofu in example directories...${NC}"
for example in examples/*/; do
    if [[ -f "${example}main.tf" ]]; then
        echo -e "${YELLOW}   Initializing ${example}...${NC}"
        (cd "$example" && tofu init -backend=false) || echo -e "${RED}   ❌ Failed to initialize ${example}${NC}"
    fi
done

# Validate modules
echo -e "\n${BLUE}🔍 Validating modules...${NC}"
for module in modules/*/; do
    if [[ -f "${module}main.tf" ]]; then
        echo -e "${YELLOW}   Validating ${module}...${NC}"
        (cd "$module" && tofu init -backend=false && tofu validate) || echo -e "${RED}   ❌ Failed to validate ${module}${NC}"
    fi
done

echo -e "\n${GREEN}🎉 Setup complete!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo -e "${YELLOW}1. Configure Google Cloud authentication (gcloud auth login)${NC}"
echo -e "${YELLOW}2. Set GOOGLE_PROJECT environment variable if needed${NC}"
echo -e "${YELLOW}3. Run 'direnv allow' to load environment${NC}"
echo -e "${YELLOW}4. Run 'task test' to validate the module${NC}"
