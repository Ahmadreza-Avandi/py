#!/bin/bash

# اسکریپت برای رفع مشکل Wayland و Qt روی Raspberry Pi

# به‌روزرسانی مخازن
echo "به‌روزرسانی مخازن سیستم..."
sudo apt update

# نصب پکیج‌های لازم برای Wayland و Qt
echo "نصب پکیج‌های لازم برای Wayland و Qt..."
sudo apt install -y \
    qtwayland5 \
    libqt5waylandclient5 \
    libqt5waylandcompositor5 \
    qt5-default \
    libqt5widgets5 \
    libqt5gui5 \
    qtbase5-dev \
    qt5-qmake

# آپدیت PyQt5 برای سازگاری با Wayland
echo "به‌روزرسانی PyQt5..."
pip3 install --upgrade pyqt5

# تنظیم متغیر محیطی برای Qt
echo "تنظیم متغیر محیطی برای استفاده از Wayland..."
if ! grep -q "QT_QPA_PLATFORM=wayland" ~/.bashrc; then
    echo 'export QT_QPA_PLATFORM=wayland' >> ~/.bashrc
fi
source ~/.bashrc

# بررسی وضعیت Wayland
echo "بررسی وضعیت Wayland..."
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "سیستم روی Wayland کار می‌کنه."
else
    echo "هشدار: سیستم روی Wayland نیست. تلاش برای تغییر به X11..."
    # تغییر به X11 در صورت نیاز
    if [ -f /etc/xdg/lxsession/LXDE-pi/desktop.conf ]; then
        sudo sed -i 's/session=wayland/session=x11/' /etc/xdg/lxsession/LXDE-pi/desktop.conf
        echo "تنظیمات به X11 تغییر کرد. لطفاً سیستم رو ریبوت کنید."
    else
        echo "فایل تنظیمات یافت نشد. لطفاً به صورت دستی بررسی کنید."
    fi
fi

# پیام نهایی
echo "تنظیمات کامل شد. لطفاً برنامه رو با این دستور اجرا کنید:"
echo "python3 faceDetectionWithCamera.py"
echo "اگر هنوز مشکل دارید، سیستم رو با این دستور ریبوت کنید:"
echo "sudo reboot"
