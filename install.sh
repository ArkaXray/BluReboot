#!/bin/bash
# BluReboot Pro - Ultimate Server Reboot Manager
# Author: BluCloud Labs
# Version: 3.1
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
# DEPENDENCY INSTALLATION
# ========================

install_gum() {
    echo -e "${YELLOW}Installing gum...${NC}"
    
    # Try official install method
    if curl -sSf https://gum.dev/install.sh | bash; then
        export PATH="$HOME/.local/bin:$PATH"
        return 0
    fi
    
    # Fallback method
    echo -e "${YELLOW}Official install failed, trying direct download...${NC}"
    
    local ARCH=$(uname -m)
    local OS=$(uname -s)
    local GUM_VERSION="0.11.0"
    
    case "$ARCH" in
        "x86_64") ARCH="amd64" ;;
        "aarch64") ARCH="arm64" ;;
        *) ARCH="amd64" ;;
    esac
    
    DOWNLOAD_URL="https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_${OS}_${ARCH}.tar.gz"
    
    sudo mkdir -p /usr/local/bin
    if curl -sSL "$DOWNLOAD_URL" | sudo tar -xz -C /usr/local/bin; then
        sudo chmod +x /usr/local/bin/gum
        return 0
    fi
    
    return 1
}

check_dependencies() {
    if ! command -v gum &> /dev/null; then
        echo -e "${YELLOW}Dependency missing: gum${NC}"
        if install_gum; then
            echo -e "${GREEN}Successfully installed gum${NC}"
        else
            echo -e "${RED}Failed to install gum. Please install manually:${NC}"
            echo "curl -sSf https://gum.dev/install.sh | bash"
            exit 1
        fi
    fi
    
    # Check for other dependencies
    for cmd in figlet; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${YELLOW}Installing $cmd...${NC}"
            sudo apt-get install -y $cmd || sudo yum install -y $cmd || brew install $cmd
        fi
    done
}

# ========================
# MAIN FUNCTIONS
# ========================

show_banner() {
    clear
    if command -v figlet &> /dev/null; then
        echo -e "${BLUE}$(figlet -f slant "BluReboot Pro")${NC}"
    else
        echo -e "${BLUE}BluReboot Pro${NC}"
    fi
    echo -e "${CYAN}Ultimate Server Reboot Manager v3.1${NC}"
    echo
}

language_selection() {
    LANG=$(gum choose --header "Select Language" \
        --cursor "> " \
        --limit 1 \
        "English" \
        "فارسی (Persian)")
}

main_menu() {
    while true; do
        if [ "$LANG" == "فارسی (Persian)" ]; then
            CHOICE=$(gum choose --header "منوی اصلی" \
                --cursor "> " \
                "📅 زمان‌بندی ریبوت" \
                "🚀 ریبوت فوری" \
                "📊 نمایش زمان‌بندی‌ها" \
                "❌ حذف زمان‌بندی" \
                "ℹ️ اطلاعات سیستم" \
                "🚪 خروج")
        else
            CHOICE=$(gum choose --header "Main Menu" \
                --cursor "> " \
                "📅 Schedule Reboot" \
                "🚀 Immediate Reboot" \
                "📊 View Schedules" \
                "❌ Remove Schedule" \
                "ℹ️ System Info" \
                "🚪 Exit")
        fi

        case "$CHOICE" in
            *"Schedule"*|*"زمان‌بندی"*)
                schedule_reboot
                ;;
            *"Immediate"*|*"فوری"*)
                immediate_reboot
                ;;
            *"View"*|*"نمایش"*)
                view_schedules
                ;;
            *"Remove"*|*"حذف"*)
                remove_schedule
                ;;
            *"System"*|*"اطلاعات"*)
                system_info
                ;;
            *"Exit"*|*"خروج"*)
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                ;;
        esac
    done
}

# ========================
# REBOOT FUNCTIONS
# ========================

schedule_reboot() {
    # Implementation here
}

immediate_reboot() {
    # Implementation here
}

view_schedules() {
    # Implementation here
}

remove_schedule() {
    # Implementation here
}

system_info() {
    # Implementation here
}

# ========================
# MAIN EXECUTION
# ========================

check_dependencies
show_banner
language_selection
main_menu
