#!/bin/bash

# رنگ‌ها برای خوانایی بیشتر
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${GREEN}[*] شروع عملیات بازگردانی سورس‌لیست و حل مشکل GPG...${RESET}"

# اضافه کردن کلید GPG برای Docker
echo -e "${GREEN}[*] اضافه کردن کلید GPG برای Docker...${RESET}"
curl -fsSL https://download.docker.com/linux/raspbian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# ساخت فایل سورس لیست امن برای Docker
echo -e "${GREEN}[*] ساخت سورس Docker با استفاده از Keyring...${RESET}"
echo "deb [arch=armhf signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/raspbian bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# تنظیم مجدد سورس لیست پیش‌فرض رزبری‌پای (Bookworm)
echo -e "${GREEN}[*] تنظیم مجدد سورس‌لیست پیش‌فرض...${RESET}"
sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb http://raspbian.raspberrypi.org/raspbian/ bookworm main contrib non-free rpi
EOF

sudo tee /etc/apt/sources.list.d/raspi.list > /dev/null <<EOF
deb http://archive.raspberrypi.org/debian/ bookworm main
EOF

# آپدیت لیست پکیج‌ها
echo -e "${GREEN}[*] اجرای apt update...${RESET}"
sudo apt update

# آپگرید سیستم
echo -e "${GREEN}[*] اجرای apt upgrade...${RESET}"
sudo apt upgrade -y

echo -e "${GREEN}[✔] همه چیز با موفقیت انجام شد! ریبوت اختیاری هست، ولی بهتره بزنی:${RESET}"
echo -e "${GREEN}sudo reboot${RESET}"

