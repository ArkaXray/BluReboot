#!/bin/bash
# BluReboot Pro - Ultimate Server Reboot Manager
# Author: BluCloud Labs
# Version: 3.4.1

set -euo pipefail
trap 'echo -e "${RED}❌ Error in line $LINENO${NC}"; exit 1' ERR

# Colors
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

# Dependency management with offline support
check_dependencies() {
    local missing_deps=()
    
    # Check for gum
    if ! command -v gum &>/dev/null; then
        missing_deps+=("gum")
    fi

    # Check for figlet
    if ! command -v figlet &>/dev/null; then
        missing_deps+=("figlet")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${YELLOW}⚠ Missing dependencies: ${missing_deps[*]}${NC}"
        
        # Try offline installation first
        if [ -f "./dependencies/local_gum" ]; then
            echo -e "${YELLOW}Attempting offline installation of gum...${NC}"
            chmod +x "./dependencies/local_gum"
            sudo cp "./dependencies/local_gum" "/usr/local/bin/gum" && \
            echo -e "${GREEN}✔ gum installed from local copy${NC}" || \
            echo -e "${RED}❌ Failed to install local gum${NC}"
        fi

        if [ -f "./dependencies/local_figlet" ]; then
            echo -e "${YELLOW}Attempting offline installation of figlet...${NC}"
            sudo cp "./dependencies/local_figlet" "/usr/local/bin/figlet" && \
            echo -e "${GREEN}✔ figlet installed from local copy${NC}" || \
            echo -e "${RED}❌ Failed to install local figlet${NC}"
        fi

        # Re-check after offline attempt
        missing_deps=()
        [ ! -x "/usr/local/bin/gum" ] && missing_deps+=("gum")
        [ ! -x "/usr/local/bin/figlet" ] && missing_deps+=("figlet")

        if [ ${#missing_deps[@]} -ne 0 ]; then
            echo -e "${YELLOW}Attempting online installation...${NC}"
            
            # Try different package managers
            if command -v apt-get &>/dev/null; then
                sudo apt-get update
                for dep in "${missing_deps[@]}"; do
                    sudo apt-get install -y "$dep" || true
                done
            elif command -v yum &>/dev/null; then
                for dep in "${missing_deps[@]}"; do
                    sudo yum install -y "$dep" || true
                done
            elif command -v brew &>/dev/null; then
                for dep in "${missing_deps[@]}"; do
                    brew install "$dep" || true
                done
            else
                echo -e "${RED}❌ No supported package manager found${NC}"
                echo -e "${YELLOW}Please install these manually: ${missing_deps[*]}${NC}"
                exit 1
            fi

            # Final verification
            for dep in "${missing_deps[@]}"; do
                if ! command -v "$dep" &>/dev/null; then
                    echo -e "${RED}❌ Failed to install $dep${NC}"
                    echo -e "${YELLOW}Please install it manually and try again${NC}"
                    exit 1
                fi
            done
        fi
    fi
}

show_banner() {
    clear
    # Fallback ASCII art if figlet isn't available
    if command -v figlet &>/dev/null; then
        echo -e "${CYAN}"
        figlet BluReboot
        echo -e "${NC}"
    else
        echo -e "${CYAN}"
        echo -e "╦ ╦┬ ┬┬┌─┐┬  ┌─┐ ┌─┐ ┌┬┐"
        echo -e "║║║│ │││ ┬│  ├┤ └─┐ │││"
        echo -e "╚╩╝└─┘┴└─┘┴─┘└─┘└─┘─┴┘"
        echo -e "${NC}"
    fi
    echo -e "${BOLD}${BLUE}Server Reboot Scheduler by BluCloud Labs${NC}\n"
}

language_selection() {
    if command -v gum &>/dev/null; then
        LANGUAGE=$(gum choose --header="🌐 Select Language / زبان را انتخاب کنید" "English" "فارسی")
    else
        # Fallback language selection
        echo -e "${YELLOW}1. English"
        echo -e "2. فارسی${NC}"
        read -rp "Select language (1-2): " lang_choice
        case $lang_choice in
            1) LANGUAGE="English" ;;
            2) LANGUAGE="فارسی" ;;
            *) LANGUAGE="English" ;;
        esac
    fi
}

schedule_reboot() {
    if command -v gum &>/dev/null; then
        OPTION=$(gum choose --header="⏰ Choose reboot interval" \
            "Every 30 minutes" "Every 1 hour" "Every 3 hours" "Every 6 hours" "Every 12 hours" "Cancel")
    else
        # Fallback menu
        echo -e "${YELLOW}Select reboot interval:${NC}"
        echo -e "1. Every 30 minutes"
        echo -e "2. Every 1 hour"
        echo -e "3. Every 3 hours"
        echo -e "4. Every 6 hours"
        echo -e "5. Every 12 hours"
        echo -e "6. Cancel"
        read -rp "Enter choice (1-6): " interval_choice
        
        case $interval_choice in
            1) OPTION="Every 30 minutes" ;;
            2) OPTION="Every 1 hour" ;;
            3) OPTION="Every 3 hours" ;;
            4) OPTION="Every 6 hours" ;;
            5) OPTION="Every 12 hours" ;;
            *) OPTION="Cancel" ;;
        esac
    fi

    case "$OPTION" in
        "Every 30 minutes") INTERVAL="*/30 * * * *" ;;
        "Every 1 hour") INTERVAL="0 * * * *" ;;
        "Every 3 hours") INTERVAL="0 */3 * * *" ;;
        "Every 6 hours") INTERVAL="0 */6 * * *" ;;
        "Every 12 hours") INTERVAL="0 */12 * * *" ;;
        "Cancel") return ;;
    esac

    if command -v gum &>/dev/null; then
        if gum confirm "✅ Confirm reboot every: $OPTION ?"; then
            (crontab -l 2>/dev/null; echo "$INTERVAL /sbin/reboot") | crontab -
            echo -e "${GREEN}✔ Reboot scheduled: $OPTION${NC}"
        else
            echo -e "${YELLOW}❌ Reboot scheduling canceled${NC}"
        fi
    else
        # Fallback confirmation
        read -rp "Confirm reboot every $OPTION? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            (crontab -l 2>/dev/null; echo "$INTERVAL /sbin/reboot") | crontab -
            echo -e "${GREEN}✔ Reboot scheduled: $OPTION${NC}"
        else
            echo -e "${YELLOW}❌ Reboot scheduling canceled${NC}"
        fi
    fi
}

remove_reboot_schedule() {
    if crontab -l 2>/dev/null | grep -q "/sbin/reboot"; then
        crontab -l 2>/dev/null | grep -v "/sbin/reboot" | crontab -
        echo -e "${GREEN}✔ All reboot schedules removed${NC}"
    else
        echo -e "${YELLOW}⚠ No reboot schedules found${NC}"
    fi
}

main_menu() {
    while true; do
        if [[ "$LANGUAGE" == "فارسی" ]]; then
            if command -v gum &>/dev/null; then
                OPTION=$(gum choose --header="🔧 انتخاب عملیات" \
                    "⏰ زمان‌بندی ریبوت" "❌ حذف زمان‌بندی" "🚪 خروج")
            else
                echo -e "${YELLOW}🔧 انتخاب عملیات${NC}"
                echo -e "1. ⏰ زمان‌بندی ریبوت"
                echo -e "2. ❌ حذف زمان‌بندی"
                echo -e "3. 🚪 خروج"
                read -rp "انتخاب کنید (1-3): " menu_choice
                case $menu_choice in
                    1) OPTION="⏰ زمان‌بندی ریبوت" ;;
                    2) OPTION="❌ حذف زمان‌بندی" ;;
                    3) OPTION="🚪 خروج" ;;
                    *) OPTION="🚪 خروج" ;;
                esac
            fi

            case "$OPTION" in
                "⏰ زمان‌بندی ریبوت") schedule_reboot ;;
                "❌ حذف زمان‌بندی") remove_reboot_schedule ;;
                "🚪 خروج") exit 0 ;;
            esac
        else
            if command -v gum &>/dev/null; then
                OPTION=$(gum choose --header="🔧 Choose an action" \
                    "⏰ Schedule reboot" "❌ Remove schedule" "🚪 Exit")
            else
                echo -e "${YELLOW}🔧 Choose an action${NC}"
                echo -e "1. ⏰ Schedule reboot"
                echo -e "2. ❌ Remove schedule"
                echo -e "3. 🚪 Exit"
                read -rp "Enter choice (1-3): " menu_choice
                case $menu_choice in
                    1) OPTION="⏰ Schedule reboot" ;;
                    2) OPTION="❌ Remove schedule" ;;
                    3) OPTION="🚪 Exit" ;;
                    *) OPTION="🚪 Exit" ;;
                esac
            fi

            case "$OPTION" in
                "⏰ Schedule reboot") schedule_reboot ;;
                "❌ Remove schedule") remove_reboot_schedule ;;
                "🚪 Exit") exit 0 ;;
            esac
        fi
    done
}

# Main execution
check_dependencies
show_banner
language_selection
main_menu
