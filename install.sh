#!/bin/bash
# BluReboot Pro - Premium Reboot Scheduler with Enhanced UI
# Author: BluCloud Labs
# Version: 2.0
# https://github.com/BluCloudLabs/BluReboot-Pro

# Color palette
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

# Check and install dependencies
install_dependencies() {
    local missing=()
    
    # Check for gum
    if ! command -v gum &> /dev/null; then
        missing+=("gum")
    fi
    
    # Check for figlet
    if ! command -v figlet &> /dev/null; then
        missing+=("figlet")
    fi
    
    # Check for lolcat
    if ! command -v lolcat &> /dev/null; then
        missing+=("lolcat")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚙️ Installing missing dependencies: ${missing[*]}${NC}"
        sudo apt update && sudo apt install -y curl figlet lolcat
        
        # Install gum if missing
        if [[ " ${missing[*]} " =~ " gum " ]]; then
            echo -e "${CYAN}📦 Installing gum...${NC}"
            curl -sSf https://gum.dev/install.sh | bash
            export PATH="$HOME/.local/bin:$PATH"
        fi
        
        # Verify installations
        for pkg in "${missing[@]}"; do
            if ! command -v "$pkg" &> /dev/null; then
                echo -e "${RED}❌ Failed to install $pkg${NC}"
                exit 1
            fi
        done
    fi
}

# Show welcome banner
show_banner() {
    clear
    gum style --border double --margin "1" --padding "2" --border-foreground 212 \
        "$(figlet -f slant "BluReboot Pro" | lolcat)" \
        "$(gum style --foreground 99 "Premium Server Reboot Scheduler v2.0")"
    echo
}

# Main menu
main_menu() {
    while true; do
        CHOICE=$(gum choose --header " $(gum style --foreground 212 'MAIN MENU') " \
            --cursor "➤ " --limit 1 \
            "📅 Schedule Reboot" \
            "🚀 Immediate Reboot" \
            "❌ Remove Schedule" \
            "📊 View Current Jobs" \
            "ℹ️ System Info" \
            "🚪 Exit")
        
        case $CHOICE in
            "📅 Schedule Reboot")
                schedule_reboot
                ;;
            "🚀 Immediate Reboot")
                confirm_reboot
                ;;
            "❌ Remove Schedule")
                remove_schedule
                ;;
            "📊 View Current Jobs")
                view_jobs
                ;;
            "ℹ️ System Info")
                system_info
                ;;
            "🚪 Exit")
                echo -e "${GREEN}👋 Exiting BluReboot Pro${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                ;;
        esac
    done
}

# Schedule reboot function
schedule_reboot() {
    INTERVAL=$(gum choose --header " $(gum style --foreground 120 'SELECT REBOOT INTERVAL') " \
        --cursor "⏱️ " \
        "Every 15 minutes" \
        "Every 30 minutes" \
        "Every 1 hour" \
        "Every 3 hours" \
        "Every 6 hours" \
        "Every 12 hours" \
        "Daily at Midnight" \
        "Weekly on Sunday" \
        "Custom Schedule" \
        "↩️ Back")
    
    if [[ "$INTERVAL" == "↩️ Back" || -z "$INTERVAL" ]]; then
        return
    fi
    
    REBOOT_CMD=$(which reboot)
    crontab -l 2>/dev/null | grep -v 'blu-reboot-pro' > /tmp/blureboot_cron
    
    case $INTERVAL in
        "Every 15 minutes") echo "*/15 * * * * $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "Every 30 minutes") echo "*/30 * * * * $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "Every 1 hour")     echo "0 * * * * $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "Every 3 hours")    echo "0 */3 * * * $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "Every 6 hours")    echo "0 */6 * * * $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "Every 12 hours")   echo "0 */12 * * * $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "Daily at Midnight") echo "0 0 * * * $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "Weekly on Sunday") echo "0 0 * * 0 $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "Custom Schedule")
            CUSTOM_TIME=$(gum input --placeholder "Enter cron schedule (e.g., '0 3 * * *' for daily at 3AM)")
            if [[ -n "$CUSTOM_TIME" ]]; then
                echo "$CUSTOM_TIME $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron
            else
                gum style --border normal --margin "1" --padding "1" --foreground 1 "⚠️ No schedule entered"
                return
            fi
            ;;
    esac
    
    crontab /tmp/blureboot_cron
    rm /tmp/blureboot_cron
    
    # Show success message
    gum style --border thick --margin "1" --padding "1 3" --border-foreground 118 \
        "$(gum style --foreground 118 "✅ SCHEDULE SET SUCCESSFULLY!")" \
        "$(gum style --faint "Reboot interval: $INTERVAL")"
    
    # Show current jobs
    view_jobs
}

# Confirm before reboot
confirm_reboot() {
    gum confirm --default="No" --affirmative="Yes, Reboot Now" --negative="Cancel" \
        "⚠️ $(gum style --foreground 208 "Are you sure you want to reboot now?")" || return
    
    # Countdown before reboot
    echo -e "${YELLOW}🚀 Initiating system reboot in 10 seconds...${NC}"
    for i in {10..1}; do
        echo -e "${RED}Rebooting in $i seconds... Press Ctrl+C to abort${NC}"
        sleep 1
    done
    
    # Execute reboot
    echo -e "${GREEN}⚡ Rebooting system now!${NC}"
    sudo reboot
}

# Remove scheduled reboots
remove_schedule() {
    crontab -l 2>/dev/null | grep -v 'blu-reboot-pro' > /tmp/blureboot_cron
    crontab /tmp/blureboot_cron
    rm /tmp/blureboot_cron
    
    gum style --border thick --margin "1" --padding "1" --border-foreground 118 \
        "$(gum style --foreground 118 "✅ ALL REBOOT SCHEDULES REMOVED")"
}

# View current cron jobs
view_jobs() {
    CURRENT_JOBS=$(crontab -l 2>/dev/null | grep 'blu-reboot-pro' || echo "No active reboot schedules")
    
    gum style --border rounded --margin "1" --padding "1" --border-foreground 99 \
        "$(gum style --underline --foreground 99 "CURRENT REBOOT SCHEDULES")" \
        "$(gum style --faint "$CURRENT_JOBS")"
    
    gum spin --spinner dot --title "Refreshing in 3 seconds..." -- sleep 3
}

# System information
system_info() {
    LAST_REBOOT=$(who -b | awk '{print $3, $4}')
    UPTIME=$(uptime -p)
    LOAD_AVG=$(uptime | awk -F'load average: ' '{print $2}')
    MEMORY=$(free -h | awk '/Mem:/ {print $3 " / " $2}')
    
    gum style --border rounded --margin "1" --padding "1" --border-foreground 57 \
        "$(gum style --underline --foreground 57 "SYSTEM INFORMATION")" \
        "$(gum style --faint "Last Reboot: $LAST_REBOOT")" \
        "$(gum style --faint "Uptime: $UPTIME")" \
        "$(gum style --faint "Load Avg: $LOAD_AVG")" \
        "$(gum style --faint "Memory Usage: $MEMORY")"
}

# Main execution
install_dependencies
show_banner
main_menu
