#!/bin/bash
# BluReboot Pro - Ultimate Server Reboot Manager
# Author: BluCloud Labs
# Version: 3.0
# URL: https://github.com/BluCloudLabs/BluReboot-Pro

# 🌐 Multilingual Support
LANG=$(gum choose --header "Select Language/زبان را انتخاب کنید" "English" "فارسی (Persian)")

# Color and Style Setup
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

# 📦 Dependency Check and Install
check_dependencies() {
    local missing=()
    
    if ! command -v gum &> /dev/null; then
        missing+=("gum")
    fi
    
    if ! command -v figlet &> /dev/null; then
        missing+=("figlet")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚙️ Installing dependencies...${NC}"
        sudo apt update && sudo apt install -y curl
        if [[ " ${missing[*]} " =~ " gum " ]]; then
            echo -e "${CYAN}📦 Installing gum...${NC}"
            curl -sSf https://gum.dev/install.sh | bash
            export PATH="$HOME/.local/bin:$PATH"
        fi
        if [[ " ${missing[*]} " =~ " figlet " ]]; then
            sudo apt install -y figlet
        fi
    fi
}

# 🎨 Show Banner
show_banner() {
    clear
    if [ "$LANG" == "فارسی (Persian)" ]; then
        echo -e "${BLUE}$(figlet -f slant "BluReboot Pro")${NC}"
        echo -e "${CYAN}مدیر پیشرفته ریبوت سرور - نسخه ۳.۰${NC}"
    else
        echo -e "${BLUE}$(figlet -f slant "BluReboot Pro")${NC}"
        echo -e "${CYAN}Ultimate Server Reboot Manager v3.0${NC}"
    fi
    echo
}

# 📅 Schedule Reboot
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

# 🚀 Immediate Reboot
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

# 📊 View Current Jobs
view_jobs() {
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

# 🗑️ Remove Schedule
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

# ℹ️ System Info
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

# � Main Menu
main_menu() {
    while true; do
        if [ "$LANG" == "فارسی (Persian)" ]; then
            CHOICE=$(gum choose --header "منوی اصلی" \
                --cursor "➤ " --limit 1 \
                "📅 زمان بندی ریبوت" \
                "🚀 ریبوت فوری" \
                "❌ حذف زمان بندی" \
                "📊 نمایش زمان بندی ها" \
                "ℹ️ اطلاعات سیستم" \
                "🚪 خروج")
        else
            CHOICE=$(gum choose --header "MAIN MENU" \
                --cursor "➤ " --limit 1 \
                "📅 Schedule Reboot" \
                "🚀 Immediate Reboot" \
                "❌ Remove Schedule" \
                "📊 View Current Jobs" \
                "ℹ️ System Info" \
                "🚪 Exit")
        fi

        case $CHOICE in
            "📅 زمان بندی ریبوت"|"📅 Schedule Reboot")
                schedule_reboot
                ;;
            "🚀 ریبوت فوری"|"🚀 Immediate Reboot")
                immediate_reboot
                ;;
            "❌ حذف زمان بندی"|"❌ Remove Schedule")
                remove_schedule
                ;;
            "📊 نمایش زمان بندی ها"|"📊 View Current Jobs")
                view_jobs
                ;;
            "ℹ️ اطلاعات سیستم"|"ℹ️ System Info")
                system_info
                ;;
            "🚪 خروج"|"🚪 Exit")
                if [ "$LANG" == "فارسی (Persian)" ]; then
                    echo -e "${GREEN}👋 با تشکر از استفاده از BluReboot Pro${NC}"
                else
                    echo -e "${GREEN}👋 Thank you for using BluReboot Pro${NC}"
                fi
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                ;;
        esac
    done
}

# 🚀 Start the script
check_dependencies
show_banner
main_menu
