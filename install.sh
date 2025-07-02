#!/bin/bash
# BluReboot - Installer with Gum interactive menu
# Author: BluCloud
# https://github.com/YOUR_USERNAME/BluReboot

# چک کردن نصب بودن gum
if ! command -v gum &> /dev/null; then
    echo "📦 Installing gum..."
    sudo apt update && sudo apt install -y curl
    curl -sSf https://gum.dev/install.sh | bash
    export PATH="$HOME/.local/bin:$PATH"
fi

# نمایش منوی انتخاب بازه ریبوت
INTERVAL=$(gum choose --header "🔄 BluReboot Installer" \
"Every 30 minutes" \
"Every 1 hour" \
"Every 3 hours" \
"Every 6 hours" \
"Every 12 hours" \
"Cancel")

if [[ "$INTERVAL" == "Cancel" || -z "$INTERVAL" ]]; then
    gum style --border double --margin "1" --padding "1" --foreground 1 "❌ Installation Cancelled"
    exit 0
fi

REBOOT_CMD=$(which reboot)
crontab -l 2>/dev/null | grep -v 'blu-reboot' > /tmp/mycron

case $INTERVAL in
    "Every 30 minutes") echo "*/30 * * * * $REBOOT_CMD # blu-reboot" >> /tmp/mycron ;;
    "Every 1 hour")     echo "0 * * * * $REBOOT_CMD # blu-reboot" >> /tmp/mycron ;;
    "Every 3 hours")    echo "0 */3 * * * $REBOOT_CMD # blu-reboot" >> /tmp/mycron ;;
    "Every 6 hours")    echo "0 */6 * * * $REBOOT_CMD # blu-reboot" >> /tmp/mycron ;;
    "Every 12 hours")   echo "0 */12 * * * $REBOOT_CMD # blu-reboot" >> /tmp/mycron ;;
esac

crontab /tmp/mycron
rm /tmp/mycron

gum style --border double --padding "1" --margin "1" --foreground 2 "✅ Reboot job set successfully!"
