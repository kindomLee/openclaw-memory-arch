#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default workspace path
DEFAULT_WORKSPACE="./clawd"

echo -e "${BLUE}OpenClaw Workspace Template Bootstrap${NC}"
echo -e "${BLUE}=====================================${NC}"
echo

# Ask for workspace path
echo -e "${YELLOW}Enter workspace directory path (default: ${DEFAULT_WORKSPACE}):${NC}"
read -r WORKSPACE_PATH

# Use default if empty
if [ -z "$WORKSPACE_PATH" ]; then
    WORKSPACE_PATH="$DEFAULT_WORKSPACE"
fi

# Convert to absolute path
# macOS compat: realpath may not exist
if command -v realpath &>/dev/null; then
    WORKSPACE_PATH=$(realpath "$WORKSPACE_PATH")
else
    WORKSPACE_PATH=$(cd "$(dirname "$WORKSPACE_PATH")" && pwd)/$(basename "$WORKSPACE_PATH")
fi

echo -e "${BLUE}Setting up workspace at: ${WORKSPACE_PATH}${NC}"
echo

# Create workspace directory if it doesn't exist
if [ ! -d "$WORKSPACE_PATH" ]; then
    echo -e "${YELLOW}Creating workspace directory...${NC}"
    mkdir -p "$WORKSPACE_PATH"
fi

# Check if workspace is empty
if [ "$(ls -A "$WORKSPACE_PATH" 2>/dev/null)" ]; then
    echo -e "${RED}Warning: Workspace directory is not empty!${NC}"
    echo -e "${YELLOW}Continue? (y/N):${NC}"
    read -r CONTINUE
    if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Aborted.${NC}"
        exit 1
    fi
fi

# Copy template files
echo -e "${YELLOW}Copying template files...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "$SCRIPT_DIR/templates" ]; then
    cp -r "$SCRIPT_DIR/templates"/* "$WORKSPACE_PATH/"
    echo -e "${GREEN}✓ Template files copied${NC}"
else
    echo -e "${RED}Error: templates/ directory not found in $SCRIPT_DIR${NC}"
    exit 1
fi

# Create additional directories
echo -e "${YELLOW}Creating additional directories...${NC}"
mkdir -p "$WORKSPACE_PATH/memory"
mkdir -p "$WORKSPACE_PATH/.learnings"
mkdir -p "$WORKSPACE_PATH/scripts"
mkdir -p "$WORKSPACE_PATH/reference"
mkdir -p "$WORKSPACE_PATH/tmp"
echo -e "${GREEN}✓ Directory structure created${NC}"

# Set permissions
echo -e "${YELLOW}Setting permissions...${NC}"
chmod 755 "$WORKSPACE_PATH"
chmod 644 "$WORKSPACE_PATH"/*.md
if [ -d "$WORKSPACE_PATH/scripts" ]; then
    find "$WORKSPACE_PATH/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
fi
echo -e "${GREEN}✓ Permissions set${NC}"

# Success message
echo
echo -e "${GREEN}✨ Workspace setup complete!${NC}"
echo
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. ${YELLOW}Fill in USER.md with your information${NC}"
echo -e "2. ${YELLOW}Customize IDENTITY.md for your agent's personality${NC}"
echo -e "3. ${YELLOW}Configure OpenClaw to use workspace: ${WORKSPACE_PATH}${NC}"
echo -e "4. ${YELLOW}Review and customize AGENTS.md for your workflows${NC}"
echo -e "5. ${YELLOW}Add your specific tools and services to TOOLS.md${NC}"
echo
echo -e "${BLUE}Workspace location: ${WORKSPACE_PATH}${NC}"
echo -e "${BLUE}Documentation: ${WORKSPACE_PATH}/guides/${NC}"
echo
echo -e "${GREEN}Happy agent building! 🤖${NC}"