#!/bin/bash

# به‌روزرسانی لیست پکیج‌ها
echo "به‌روزرسانی لیست پکیج‌ها..."
sudo apt update

# نصب پکیج‌های مورد نیاز برای Wayland و Qt
echo "نصب پکیج‌های Wayland و Qt..."
sudo apt install -y \
    qtwayland5 \
    libqt5waylandclient5 \
    libqt5waylandcompositor5 \
    qt5-default \
    libqt5widgets5 \
    libqt5gui5 \
    qtbase5-dev \
    qt5-qmake

# بررسی و تنظیم متغیر محیطی برای Qt
echo "تنظیم متغیر محیطی برای Qt..."
echo 'export QT_QPA_PLATFORM=wayland' >> ~/.bashrc
source ~/.bashrc

# آپدیت PyQt5 برای سازگاری با Wayland
echo "آپدیت PyQt5..."
pip3 install --upgrade pyqt5

# بررسی وضعیت Wayland
echo "بررسی وضعیت Wayland..."
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "سیستم روی Wayland کار می‌کنه. تنظیمات اعمال شد."
else
    echo "هشدار: سیستم روی Wayland نیست. ممکنه نیاز به تغییر تنظیمات دستی باشه."
fi

# پیام نهایی
echo "نصب و تنظیمات کامل شد. برنامه‌ت رو با این دستور اجرا کن:"
echo "python3 faceDetectionWithCamera.py"
