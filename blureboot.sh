#!/bin/bash
# BluReboot Pro - Ultimate Server Reboot Manager
# Author: BluCloud Labs
# Version: 3.4

set -euo pipefail
trap 'echo -e "${RED}❌ Error in line $LINENO${NC}"; exit 1' ERR

# رنگ‌ها
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

install_gum() {
    echo -e "${YELLOW}Installing gum from official script...${NC}"
    
    # نصب از طریق اسکریپت رسمی
    curl -sSf https://gum.dev/install.sh | bash

    # افزودن مسیر نصب به PATH
    export PATH="$HOME/.local/bin:$PATH"

    # بررسی نصب
    if command -v gum &>/dev/null; then
        echo -e "${GREEN}✔ gum installed successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ gum installation failed${NC}"
        return 1
    fi
}

check_dependencies() {
    if ! command -v gum &>/dev/null; then
        echo -e "${YELLOW}🔍 gum not found. Installing...${NC}"
        install_gum || {
            echo -e "${RED}❌ Failed to install gum${NC}"
            exit 1
        }
    fi

    if ! command -v figlet &>/dev/null; then
        echo -e "${YELLOW}Installing figlet...${NC}"
        sudo apt-get install -y figlet 2>/dev/null ||
        sudo yum install -y figlet 2>/dev/null ||
        brew install figlet 2>/dev/null || {
            echo -e "${RED}❌ Failed to install figlet${NC}"
            exit 1
        }
    fi
}

show_banner() {
    clear
    echo -e "${CYAN}"
    figlet BluReboot
    echo -e "${NC}"
    echo -e "${BOLD}${BLUE}Server Reboot Scheduler by BluCloud Labs${NC}\n"
}

language_selection() {
    LANGUAGE=$(gum choose --header="🌐 Select Language / زبان را انتخاب کنید" "English" "فارسی")
}

schedule_reboot() {
    OPTION=$(gum choose --header="⏰ Choose reboot interval" \
        "Every 30 minutes" "Every 1 hour" "Every 3 hours" "Every 6 hours" "Every 12 hours" "Cancel")
    case "$OPTION" in
        "Every 30 minutes") INTERVAL="*/30 * * * *" ;;
        "Every 1 hour") INTERVAL="0 * * * *" ;;
        "Every 3 hours") INTERVAL="0 */3 * * *" ;;
        "Every 6 hours") INTERVAL="0 */6 * * *" ;;
        "Every 12 hours") INTERVAL="0 */12 * * *" ;;
        "Cancel") return ;;
    esac
    if gum confirm "✅ Confirm reboot every: $OPTION ?"; then
        (crontab -l 2>/dev/null; echo "$INTERVAL /sbin/reboot") | crontab -
        echo -e "${GREEN}✔ Reboot scheduled: $OPTION${NC}"
    else
        echo -e "${YELLOW}❌ Reboot scheduling canceled${NC}"
    fi
}

remove_reboot_schedule() {
    crontab -l 2>/dev/null | grep -v "/sbin/reboot" | crontab -
    echo -e "${GREEN}✔ All reboot schedules removed${NC}"
}

main_menu() {
    while true; do
        if [[ "$LANGUAGE" == "فارسی" ]]; then
            OPTION=$(gum choose --header="🔧 انتخاب عملیات" \
                "⏰ زمان‌بندی ریبوت" "❌ حذف زمان‌بندی" "🚪 خروج")
            case "$OPTION" in
                "⏰ زمان‌بندی ریبوت") schedule_reboot ;;
                "❌ حذف زمان‌بندی") remove_reboot_schedule ;;
                "🚪 خروج") exit 0 ;;
            esac
        else
            OPTION=$(gum choose --header="🔧 Choose an action" \
                "⏰ Schedule reboot" "❌ Remove schedule" "🚪 Exit")
            case "$OPTION" in
                "⏰ Schedule reboot") schedule_reboot ;;
                "❌ Remove schedule") remove_reboot_schedule ;;
                "🚪 Exit") exit 0 ;;
            esac
        fi
    done
}

# اجرای برنامه
check_dependencies
show_banner
language_selection
main_menu
