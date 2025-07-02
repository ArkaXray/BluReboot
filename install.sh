#!/bin/bash
# BluReboot Pro - Ultimate Server Reboot Manager
# Author: BluCloud Labs
# Version: 3.2
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
    echo -e "${CYAN}Ultimate Server Reboot Manager v3.2${NC}"
    echo
}

language_selection() {
    LANG=$(gum choose --header "Select Language" \
        --cursor "> " \
        --limit 1 \
        "English" \
        "فارسی (Persian)")
}

# ========================
# REBOOT FUNCTIONS
# ========================

schedule_reboot() {
    if [ "$LANG" == "فارسی (Persian)" ]; then
        INTERVAL=$(gum choose --header "بازه زمانی ریبوت را انتخاب کنید" \
            "هر 30 دقیقه" \
            "هر 1 ساعت" \
            "هر 3 ساعت" \
            "هر 6 ساعت" \
            "هر 12 ساعت" \
            "هر روز نیمه شب" \
            "هر هفته یکشنبه" \
            "زمان بندی سفارشی" \
            "بازگشت")
    else
        INTERVAL=$(gum choose --header "Select reboot interval" \
            "Every 30 minutes" \
            "Every 1 hour" \
            "Every 3 hours" \
            "Every 6 hours" \
            "Every 12 hours" \
            "Daily at Midnight" \
            "Weekly on Sunday" \
            "Custom Schedule" \
            "Back")
    fi

    [[ "$INTERVAL" == "بازگشت" || "$INTERVAL" == "Back" ]] && return

    REBOOT_CMD=$(which reboot)
    crontab -l 2>/dev/null | grep -v 'blu-reboot-pro' > /tmp/blureboot_cron

    case $INTERVAL in
        "هر 30 دقیقه"|"Every 30 minutes") echo "*/30 * * * * $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "هر 1 ساعت"|"Every 1 hour") echo "0 * * * * $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "هر 3 ساعت"|"Every 3 hours") echo "0 */3 * * * $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "هر 6 ساعت"|"Every 6 hours") echo "0 */6 * * * $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "هر 12 ساعت"|"Every 12 hours") echo "0 */12 * * * $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "هر روز نیمه شب"|"Daily at Midnight") echo "0 0 * * * $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "هر هفته یکشنبه"|"Weekly on Sunday") echo "0 0 * * 0 $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron ;;
        "زمان بندی سفارشی"|"Custom Schedule")
            if [ "$LANG" == "فارسی (Persian)" ]; then
                CUSTOM_TIME=$(gum input --placeholder "زمان کرون را وارد کنید (مثال: 0 3 * * * برای هر روز ساعت 3 صبح)")
            else
                CUSTOM_TIME=$(gum input --placeholder "Enter cron schedule (e.g., '0 3 * * *' for daily at 3AM)")
            fi
            [[ -n "$CUSTOM_TIME" ]] && echo "$CUSTOM_TIME $REBOOT_CMD # blu-reboot-pro" >> /tmp/blureboot_cron
            ;;
    esac

    crontab /tmp/blureboot_cron
    rm /tmp/blureboot_cron

    if [ "$LANG" == "فارسی (Persian)" ]; then
        gum style --border thick --margin "1" --padding "1 3" --border-foreground 118 \
            "$(gum style --foreground 118 "✅ زمان بندی با موفقیت تنظیم شد!")" \
            "$(gum style --faint "بازه زمانی: $INTERVAL")"
    else
        gum style --border thick --margin "1" --padding "1 3" --border-foreground 118 \
            "$(gum style --foreground 118 "✅ SCHEDULE SET SUCCESSFULLY!")" \
            "$(gum style --faint "Reboot interval: $INTERVAL")"
    fi
}

immediate_reboot() {
    if [ "$LANG" == "فارسی (Persian)" ]; then
        gum confirm --default="No" --affirmative="بله، ریبوت کن" --negative="لغو" \
            "⚠️ $(gum style --foreground 208 "آیا مطمئنید می خواهید سیستم را ریبوت کنید؟")" || return
    else
        gum confirm --default="No" --affirmative="Yes, Reboot Now" --negative="Cancel" \
            "⚠️ $(gum style --foreground 208 "Are you sure you want to reboot now?")" || return
    fi

    if [ "$LANG" == "فارسی (Persian)" ]; then
        echo -e "${YELLOW}🚀 سیستم در 10 ثانیه ریبوت خواهد شد...${NC}"
    else
        echo -e "${YELLOW}🚀 Initiating system reboot in 10 seconds...${NC}"
    fi
    
    for i in {10..1}; do
        if [ "$LANG" == "فارسی (Persian)" ]; then
            echo -e "${RED}ریبوت در $i ثانیه... برای لغو Ctrl+C را فشار دهید${NC}"
        else
            echo -e "${RED}Rebooting in $i seconds... Press Ctrl+C to abort${NC}"
        fi
        sleep 1
    done
    
    echo -e "${GREEN}⚡ در حال ریبوت سیستم!${NC}" | gum spin --spinner line --title "Rebooting..." -- sudo reboot
}

view_schedules() {
    CURRENT_JOBS=$(crontab -l 2>/dev/null | grep 'blu-reboot-pro' || 
        if [ "$LANG" == "فارسی (Persian)" ]; then
            echo "هیچ زمان بندی ریبوت فعالی وجود ندارد"
        else
            echo "No active reboot schedules"
        fi)
    
    if [ "$LANG" == "فارسی (Persian)" ]; then
        gum style --border rounded --margin "1" --padding "1" --border-foreground 99 \
            "$(gum style --underline --foreground 99 "زمان بندی های فعلی")" \
            "$(gum style --faint "$CURRENT_JOBS")"
    else
        gum style --border rounded --margin "1" --padding "1" --border-foreground 99 \
            "$(gum style --underline --foreground 99 "CURRENT REBOOT SCHEDULES")" \
            "$(gum style --faint "$CURRENT_JOBS")"
    fi
}

remove_schedule() {
    crontab -l 2>/dev/null | grep -v 'blu-reboot-pro' > /tmp/blureboot_cron
    crontab /tmp/blureboot_cron
    rm /tmp/blureboot_cron
    
    if [ "$LANG" == "فارسی (Persian)" ]; then
        gum style --border thick --margin "1" --padding "1" --border-foreground 118 \
            "$(gum style --foreground 118 "✅ تمام زمان بندی های ریبوت حذف شدند")"
    else
        gum style --border thick --margin "1" --padding "1" --border-foreground 118 \
            "$(gum style --foreground 118 "✅ ALL REBOOT SCHEDULES REMOVED")"
    fi
}

system_info() {
    LAST_REBOOT=$(who -b | awk '{print $3, $4}')
    UPTIME=$(uptime -p)
    LOAD_AVG=$(uptime | awk -F'load average: ' '{print $2}')
    MEMORY=$(free -h | awk '/Mem:/ {print $3 " / " $2}')
    
    if [ "$LANG" == "فارسی (Persian)" ]; then
        gum style --border rounded --margin "1" --padding "1" --border-foreground 57 \
            "$(gum style --underline --foreground 57 "اطلاعات سیستم")" \
            "$(gum style --faint "آخرین ریبوت: $LAST_REBOOT")" \
            "$(gum style --faint "مدت فعالیت: $UPTIME")" \
            "$(gum style --faint "میانگین بار: $LOAD_AVG")" \
            "$(gum style --faint "مصرف حافظه: $MEMORY")"
    else
        gum style --border rounded --margin "1" --padding "1" --border-foreground 57 \
            "$(gum style --underline --foreground 57 "SYSTEM INFORMATION")" \
            "$(gum style --faint "Last Reboot: $LAST_REBOOT")" \
            "$(gum style --faint "Uptime: $UPTIME")" \
            "$(gum style --faint "Load Avg: $LOAD_AVG")" \
            "$(gum style --faint "Memory Usage: $MEMORY")"
    fi
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
# MAIN EXECUTION
# ========================

check_dependencies
show_banner
language_selection
main_menu
