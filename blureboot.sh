#!/bin/bash
# BluReboot Pro - Server Reboot Manager (No Gum Version)
# Version: 3.4.2

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

check_dependencies() {
    if ! command -v figlet &>/dev/null; then
        echo -e "${YELLOW}Installing figlet...${NC}"
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y figlet
        elif command -v yum &>/dev/null; then
            sudo yum install -y figlet
        elif command -v brew &>/dev/null; then
            brew install figlet
        else
            echo -e "${YELLOW}Figlet not found but optional. Continuing without it.${NC}"
        fi
    fi
}

show_banner() {
    clear
    if command -v figlet &>/dev/null; then
        echo -e "${CYAN}"
        figlet BluReboot
        echo -e "${NC}"
    else
        echo -e "${CYAN}"
        echo "╦ ╦┬ ┬┬┌─┐┬  ┌─┐ ┌─┐ ┌┬┐"
        echo "║║║│ │││ ┬│  ├┤ └─┐ │││"
        echo "╚╩╝└─┘┴└─┘┴─┘└─┘└─┘─┴┘"
        echo -e "${NC}"
    fi
    echo -e "${BOLD}${BLUE}Server Reboot Scheduler by BluCloud Labs${NC}\n"
}

show_menu() {
    echo -e "${BOLD}${YELLOW}Main Menu:${NC}"
    echo -e "1) ⏰ Schedule reboot"
    echo -e "2) ❌ Remove scheduled reboots"
    echo -e "3) 🚪 Exit"
    echo -ne "${BOLD}Your choice (1-3): ${NC}"
}

schedule_reboot() {
    echo -e "\n${BOLD}${YELLOW}Schedule Options:${NC}"
    echo "1) Every 30 minutes"
    echo "2) Every 1 hour"
    echo "3) Every 3 hours"
    echo "4) Every 6 hours"
    echo "5) Every 12 hours"
    echo "6) Cancel"
    echo -ne "${BOLD}Select interval (1-6): ${NC}"
    
    read choice
    case $choice in
        1) INTERVAL="*/30 * * * *"; NAME="Every 30 minutes" ;;
        2) INTERVAL="0 * * * *"; NAME="Every 1 hour" ;;
        3) INTERVAL="0 */3 * * *"; NAME="Every 3 hours" ;;
        4) INTERVAL="0 */6 * * *"; NAME="Every 6 hours" ;;
        5) INTERVAL="0 */12 * * *"; NAME="Every 12 hours" ;;
        6) return ;;
        *) echo -e "${RED}Invalid choice${NC}"; return ;;
    esac

    echo -ne "${BOLD}Confirm schedule $NAME? (y/n): ${NC}"
    read confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        (crontab -l 2>/dev/null; echo "$INTERVAL /sbin/reboot") | crontab -
        echo -e "${GREEN}✔ Scheduled: $NAME${NC}"
    else
        echo -e "${YELLOW}Schedule canceled${NC}"
    fi
}

remove_schedule() {
    if crontab -l | grep -q "/sbin/reboot"; then
        crontab -l | grep -v "/sbin/reboot" | crontab -
        echo -e "${GREEN}✔ Removed all reboot schedules${NC}"
    else
        echo -e "${YELLOW}No reboot schedules found${NC}"
    fi
}

main() {
    check_dependencies
    show_banner
    
    while true; do
        show_menu
        read choice
        
        case $choice in
            1) schedule_reboot ;;
            2) remove_schedule ;;
            3) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid choice${NC}" ;;
        esac
        
        echo
    done
}

main
