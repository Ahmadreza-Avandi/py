#!/bin/bash

# خروج از دایرکتوری فعلی و رفتن به دایرکتوری اصلی کاربر (معمولاً /home/pi)
cd /home/pi
echo "وارد دایرکتوری اصلی شدیم: $(pwd)"

# تنظیم آدرس IP استاتیک
INTERFACE="eth0"  # برای شبکه سیمی (برای وای‌فای wlan0 رو جایگزین کن)
IP_ADDRESS="192.168.1.100"  # آدرس IP دلخواه
NETMASK="255.255.255.0"  # ماسک زیرشبکه
GATEWAY="192.168.1.1"  # دروازه پیش‌فرض

# تنظیم آدرس IP
sudo ip addr flush dev $INTERFACE
sudo ip addr add $IP_ADDRESS/$NETMASK dev $INTERFACE
sudo ip route add default via $GATEWAY

# نمایش تنظیمات شبکه
echo "تنظیمات شبکه اعمال شد:"
ip addr show $INTERFACE
