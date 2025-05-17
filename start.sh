#!/bin/bash

# بررسی دسترسی به اینترنت
echo "Checking internet connection..."
if ! ping -c 1 google.com &> /dev/null; then
    echo "Error: No internet connection. Please check your network and try again."
    exit 1
fi

# تنظیم مخزن ایرانی برای دور زدن تحریم‌ها
echo "Setting up Iranian mirror for apt..."
sudo sed -i 's|http://raspbian.raspberrypi.org|http://mirror.rasanegar.com/raspbian|' /etc/apt/sources.list
sudo sed -i 's|http://archive.raspberrypi.org|http://mirror.rasanegar.com/raspberrypi|' /etc/apt/sources.list.d/raspi.list

# آپدیت لیست پکیج‌ها
echo "Updating package lists..."
sudo apt update
if [ $? -ne 0 ]; then
    echo "Error: Failed to update package lists. Check your internet or mirror settings."
    exit 1
fi

# نصب پیش‌نیازهای لازم برای پایتون
echo "Installing prerequisites for Python..."
sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev curl libbz2-dev

# آپدیت سیستم و پکیج‌های موجود
echo "Upgrading system and packages..."
sudo apt upgrade -y

# تلاش برای نصب مخزن deadsnakes برای نسخه‌های جدیدتر پایتون
echo "Attempting to add deadsnakes PPA for newer Python versions..."
sudo apt install -y software-properties-common
if sudo add-apt-repository -y ppa:deadsnakes/ppa; then
    sudo apt update
    echo "Installing Python 3.11..."
    sudo apt install -y python3.11 python3.11-dev python3.11-venv
else
    echo "Warning: Could not add deadsnakes PPA. Continuing with default Python version."
fi

# آپدیت pip
echo "Updating pip..."
sudo python3 -m pip install --upgrade pip

# تنظیم IP استاتیک برای eth0
echo "Configuring static IP for eth0..."
sudo bash -c 'cat << EOF >> /etc/dhcpcd.conf
interface eth0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1
EOF'

# ری‌استارت سرویس شبکه
echo "Restarting network service..."
sudo service dhcpcd restart
if [ $? -ne 0 ]; then
    echo "Error: Failed to restart network service. Please check your network configuration."
    exit 1
fi

echo "Setup completed successfully! Raspberry Pi IP is now 192.168.1.100."
