#!/bin/bash
# BluReboot Pro - Reliable Server Reboot Manager
# Author: BluCloud Labs
# Version: 3.4.2

set -euo pipefail
trap 'echo -e "\033[0;31m❌ Error at line $LINENO\033[0m"; exit 1' ERR

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# --- Dependency Installer ---
check_dependencies() {
    missing=()

    command -v gum &>/dev/null || missing+=("gum")
    command -v figlet &>/dev/null || missing+=("figlet")

    if [ ${#missing[@]} -eq 0 ]; then return; fi

    echo -e "${YELLOW}⚠ Missing: ${missing[*]}${NC}"

    # Try offline installation
    for dep in "${missing[@]}"; do
        local_path="./dependencies/local_${dep}"
        if [ -f "$local_path" ]; then
            echo -e "${YELLOW}Installing $dep from local copy...${NC}"
            chmod +x "$local_path"
            sudo cp "$local_path" "/usr/local/bin/$dep"
        fi
    done

    # Re-check
    final_missing=()
    for dep in "${missing[@]}"; do
        command -v "$dep" &>/dev/null || final_missing+=("$dep")
    done

    if [ ${#final_missing[@]} -eq 0 ]; then return; fi

    # Try online if possible
    echo -e "${YELLOW}🌐 Trying online install...${NC}"
    if ping -c 1 google.com &>/dev/null; then
        if command -v apt-get &>/dev/null; then
            sudo apt-get update
            for dep in "${final_missing[@]}"; do sudo apt-get install -y "$dep"; done
        elif command -v yum &>/dev/null; then
            for dep in "${final_missing[@]}"; do sudo yum install -y "$dep"; done
        elif command -v brew &>/dev/null; then
            for dep in "${final_missing[@]}"; do brew install "$dep"; done
        else
            echo -e "${RED}❌ No known package manager found${NC}"
            exit 1
        fi
    else
        echo -e "${RED}❌ No internet and missing dependencies: ${final_missing[*]}${NC}"
        exit 1
    fi
}

# --- Banner ---
show_banner() {
    clear
    echo -e "${CYAN}"
    if command -v figlet &>/dev/null; then figlet BluReboot
    else echo -e "=== BluReboot ==="
    fi
    echo -e "${NC}${BOLD}${BLUE}Server Reboot Scheduler by BluCloud Labs${NC}\n"
}

# --- Language ---
language_selection() {
    if command -v gum &>/dev/null; then
        LANGUAGE=$(gum choose --header="🌐 Select Language / زبان را انتخاب کنید" "English" "فارسی")
    else
        echo -e "${YELLOW}1. English\n2. فارسی${NC}"
        read -rp "Choose language (1/2): " l
        [[ $l == 2 ]] && LANGUAGE="فارسی" || LANGUAGE="English"
    fi
}

# --- Reboot Plan ---
schedule_reboot() {
    local OPTION

    if command -v gum &>/dev/null; then
        OPTION=$(gum choose --header="⏰ Choose reboot interval" \
            "Every 30 minutes" "Every 1 hour" "Every 3 hours" "Every 6 hours" "Every 12 hours" "Cancel")
    else
        echo -e "${YELLOW}Select Reboot Interval:${NC}"
        echo "1) Every 30 minutes"
        echo "2) Every 1 hour"
        echo "3) Every 3 hours"
        echo "4) Every 6 hours"
        echo "5) Every 12 hours"
        echo "6) Cancel"
        read -rp "Choice (1-6): " c
        case $c in
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
        gum confirm "✅ Confirm reboot every: $OPTION ?" && {
            (crontab -l 2>/dev/null; echo "$INTERVAL /sbin/reboot") | crontab -
            echo -e "${GREEN}✔ Scheduled reboot: $OPTION${NC}"
        }
    else
        read -rp "Confirm reboot every $OPTION? (y/n): " ok
        [[ $ok =~ ^[Yy]$ ]] && {
            (crontab -l 2>/dev/null; echo "$INTERVAL /sbin/reboot") | crontab -
            echo -e "${GREEN}✔ Reboot scheduled: $OPTION${NC}"
        }
    fi
}

remove_reboot_schedule() {
    crontab -l 2>/dev/null | grep -v "/sbin/reboot" | crontab -
    echo -e "${GREEN}✔ All reboot tasks removed${NC}"
}

# --- Main Menu ---
main_menu() {
    while true; do
        if [[ "$LANGUAGE" == "فارسی" ]]; then
            if command -v gum &>/dev/null; then
                OPTION=$(gum choose "⏰ زمان‌بندی ریبوت" "❌ حذف زمان‌بندی" "🚪 خروج")
            else
                echo -e "${YELLOW}1. زمان‌بندی ریبوت\n2. حذف زمان‌بندی\n3. خروج${NC}"
                read -rp "انتخاب شما: " m
                case $m in
                    1) OPTION="⏰ زمان‌بندی ریبوت" ;;
                    2) OPTION="❌ حذف زمان‌بندی" ;;
                    *) OPTION="🚪 خروج" ;;
                esac
            fi
            case $OPTION in
                "⏰ زمان‌بندی ریبوت") schedule_reboot ;;
                "❌ حذف زمان‌بندی") remove_reboot_schedule ;;
                *) exit 0 ;;
            esac
        else
            if command -v gum &>/dev/null; then
                OPTION=$(gum choose "⏰ Schedule reboot" "❌ Remove schedule" "🚪 Exit")
            else
                echo -e "${YELLOW}1. Schedule reboot\n2. Remove schedule\n3. Exit${NC}"
                read -rp "Enter choice: " m
                case $m in
                    1) OPTION="⏰ Schedule reboot" ;;
                    2) OPTION="❌ Remove schedule" ;;
                    *) OPTION="🚪 Exit" ;;
                esac
            fi
            case $OPTION in
                "⏰ Schedule reboot") schedule_reboot ;;
                "❌ Remove schedule") remove_reboot_schedule ;;
                *) exit 0 ;;
            esac
        fi
    done
}

# --- Run ---
check_dependencies
show_banner
language_selection
main_menu
