#!/bin/bash

# پشتیبان‌گیری از فایل‌های تنظیمات فعلی
sudo cp /etc/network/interfaces /etc/network/interfaces.bak
sudo cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.bak

# ریست فایل interfaces به حالت پیش‌فرض
echo "auto lo" | sudo tee /etc/network/interfaces
echo "iface lo inet loopback" | sudo tee -a /etc/network/interfaces
echo "" | sudo tee -a /etc/network/interfaces
echo "auto eth0" | sudo tee -a /etc/network/interfaces
echo "iface eth0 inet dhcp" | sudo tee -a /etc/network/interfaces

# ریست تنظیمات وای‌فای (اگه از وای‌فای استفاده می‌کنی)
echo "ctrl_interface=DIR=/var/run/ wpa_supplicant GROUP=netdev" | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf
echo "update_config=1" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf
echo "country=US" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf

# ریستارت سرویس شبکه
sudo systemctl restart networking
sudo systemctl restart wpa_supplicant

# ریستارت رزبری پای
echo "رزبری پای داره ریستارت می‌شه..."
sudo reboot
