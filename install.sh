#!/bin/bash
# BluReboot Pro - Ultimate Server Reboot Manager
# Author: BluCloud Labs
# Version: 3.3
# URL: https://github.com/BluCloudLabs/BluReboot-Pro

# ========================
# INITIAL SETUP
# ========================

# Error handling
set -euo pipefail
trap 'echo -e "${RED}Error in line $LINENO${NC}"; exit 1' ERR

# Colors
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

# ========================
# IMPROVED GUM INSTALLATION
# ========================

install_gum() {
    echo -e "${YELLOW}Installing gum...${NC}"
    
    # Method 1: Official install script
    echo -e "${CYAN}Trying official install method...${NC}"
    if curl -sSf https://gum.dev/install.sh | bash; then
        export PATH="$HOME/.local/bin:$PATH"
        echo -e "${GREEN}Successfully installed via official script${NC}"
        return 0
    fi
    
    # Method 2: Direct binary download (new URL format)
    echo -e "${CYAN}Trying direct binary download...${NC}"
    
    local ARCH=$(uname -m)
    local OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    local GUM_VERSION="0.12.0"
    
    # Architecture mapping
    case "$ARCH" in
        "x86_64") ARCH="amd64" ;;
        "aarch64") ARCH="arm64" ;;
        "armv7l") ARCH="arm" ;;
        *) ARCH="amd64" ;;
    esac
    
    # OS mapping
    case "$OS" in
        "darwin") OS="Darwin" ;;
        "linux") OS="Linux" ;;
        *) OS="Linux" ;;
    esac
    
    DOWNLOAD_URL="https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_${OS}_${ARCH}.tar.gz"
    
    echo -e "${YELLOW}Downloading from: $DOWNLOAD_URL${NC}"
    
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    curl -sSL "$DOWNLOAD_URL" -o "$TEMP_DIR/gum.tar.gz" || return 1
    
    # Extract and install
    tar -xzf "$TEMP_DIR/gum.tar.gz" -C "$TEMP_DIR" || return 1
    sudo mv "$TEMP_DIR/gum" /usr/local/bin/ || return 1
    sudo chmod +x /usr/local/bin/gum
    
    # Cleanup
    rm -rf "$TEMP_DIR"
    
    # Verify installation
    if command -v gum &> /dev/null; then
        echo -e "${GREEN}Successfully installed via direct download${NC}"
        return 0
    fi
    
    return 1
}

check_dependencies() {
    # Check for gum first
    if ! command -v gum &> /dev/null; then
        echo -e "${YELLOW}Dependency missing: gum${NC}"
        if install_gum; then
            echo -e "${GREEN}Successfully installed gum${NC}"
        else
            echo -e "${RED}Failed to install gum. Please install manually:${NC}"
            echo "curl -sSf https://gum.dev/install.sh | bash"
            echo "Or download from: https://github.com/charmbracelet/gum/releases"
            exit 1
        fi
    fi
    
    # Check for other dependencies
    for cmd in figlet; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${YELLOW}Installing $cmd...${NC}"
            sudo apt-get install -y $cmd 2>/dev/null || 
            sudo yum install -y $cmd 2>/dev/null || 
            brew install $cmd 2>/dev/null || {
                echo -e "${RED}Failed to install $cmd${NC}"
                exit 1
            }
        fi
    done
}

# ========================
# MAIN SCRIPT (rest of the functions remain the same as in previous complete version)
# ========================

# [Include all the other functions from the previous complete version here...]

# ========================
# EXECUTION
# ========================

check_dependencies
show_banner
language_selection
main_menu
