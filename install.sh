#!/bin/bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}📦 Installing BluReboot...${NC}"

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="blureboot"
SCRIPT_URL="https://raw.githubusercontent.com/ArkaXray/BluReboot/main/blureboot.sh"

# دانلود اسکریپت اصلی
curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_NAME"
chmod +x "$SCRIPT_NAME"

# انتقال به مسیر اجرایی
sudo mv "$SCRIPT_NAME" "$INSTALL_DIR/"

echo -e "${GREEN}✅ BluReboot installed successfully!${NC}"
echo -e "${YELLOW}👉 Run it with: ${NC}${GREEN}sudo blureboot${NC}"
