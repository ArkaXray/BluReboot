#!/bin/bash

# رنگ‌ها برای زیبایی
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}📦 در حال نصب BluReboot...${NC}"

# مسیر فایل و نصب
SCRIPT_NAME="blureboot"
INSTALL_DIR="/usr/local/bin"
RAW_URL="https://raw.githubusercontent.com/ArkaXray/BluReboot/main/blureboot.sh"

# دانلود فایل
curl -fsSL "$RAW_URL" -o "$SCRIPT_NAME"
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ دانلود اسکریپت ناموفق بود${NC}"
    exit 1
fi

chmod +x "$SCRIPT_NAME"

# انتقال به مسیر اجرایی
sudo mv "$SCRIPT_NAME" "$INSTALL_DIR/" || {
    echo -e "${RED}❌ انتقال فایل به $INSTALL_DIR ناموفق بود${NC}"
    exit 1
}

# موفقیت
echo -e "${GREEN}✅ BluReboot با موفقیت نصب شد!${NC}"
echo -e "${YELLOW}👉 اجرا کن با دستور: ${GREEN}sudo blureboot${NC}"
