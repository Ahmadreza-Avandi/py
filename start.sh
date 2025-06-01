#!/usr/bin/env bash
# -------------------------------
# setup_camera_network.sh
# یه اسکریپت برای:
# 1) نصب Qt/Wayland و OpenCV-related packages
# 2) نصب redis/mysql client و ماژول‌های Python
# 3) کانفیگ شبکه‌ی eth0 برای ارتباط مستقیم با دوربین
# -------------------------------

set -e

echo "===== آپدیت مخازن و نصب پکیج‌های اصلی ====="
sudo apt update
sudo apt upgrade -y

# ——————————————————————————————————————
# ۱. نصب کتابخونه‌های Qt5/Wayland (برای cv2.imshow و Qt-backend)
# ——————————————————————————————————————
echo "نصب Qt5 و Wayland dependencies..."
sudo apt install -y \
    qt5-default \
    libqt5gui5 \
    libqt5widgets5 \
    libqt5core5a \
    libqt5gui5 \
    libqt5waylandclient5 \
    libqt5waylandcompositor5 \
    libqt5waylandcursor5 \
    libwayland-client0 \
    libwayland-cursor0 \
    libwayland-egl1 \
    libwayland-server0 \
    build-essential \
    pkg-config

# ——————————————————————————————————————
# ۲. نصب OpenCV (Python bindings) + contrib modules
# ——————————————————————————————————————
echo "نصب OpenCV از مخازن (system-wide)..."
sudo apt install -y python3-opencv

# اگر می‌خواهی حتماً نسخه‌ی pip-based بگیری (احتمالاً سنگین باشه):
# pip install --upgrade pip setuptools wheel
# pip install opencv-contrib-python

# ——————————————————————————————————————
# ۳. نصب کلاینت‌های Redis و MySQL برای Python
# ——————————————————————————————————————
echo "نصب redis-server و mysql client (کتابخونه‌ها)..."
sudo apt install -y redis-server libmysqlclient-dev python3-dev

# توی virtualenv اگر می‌خوای ماژول پایتون‌شو نصب کنی (به شرط اینکه فعال باشه):
if [ -d "myenv" ] && [ -f "myenv/bin/activate" ]; then
    echo "فعالسازی myenv و نصب python modules..."
    source myenv/bin/activate
    pip install --upgrade pip setuptools wheel
    pip install redis mysqlclient
    deactivate
else
    echo "پوشه‌ی myenv پیدا نشد، فرض کردیم virtualenv نداریم یا توش نیستی."
fi

# ——————————————————————————————————————
# ۴. نصب dnsmasq برای DHCP سبک‌وزن
# ——————————————————————————————————————
echo "نصب dnsmasq (برای DHCP server روی eth0)..."
sudo apt install -y dnsmasq

# ——————————————————————————————————————
# ۵. کانفیگ /etc/dhcpcd.conf برای eth0 استاتیک IP
# ——————————————————————————————————————
echo "کانفیگ /etc/dhcpcd.conf برای eth0 استاتیک IP دادن..."
# Backup
sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.backup_camera

# اگر خط مشابه هست، اول حذف کن
sudo sed -i '/^interface eth0/,+1 d' /etc/dhcpcd.conf

# اضافه کردن در انتها
sudo tee -a /etc/dhcpcd.conf << 'EOF'

# -----------------------------
# Static IP for eth0 (camera network)
interface eth0
static ip_address=192.168.100.1/24
static routers=
static domain_name_servers=
# -----------------------------
EOF

# ——————————————————————————————————————
# ۶. کانفیگ dnsmasq برای DHCP بین 192.168.100.50–100
# ——————————————————————————————————————
echo "کانفیگ dnsmasq برای دادن DHCP به دوربین (192.168.100.x)..."
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup_camera

# Disable any default conf (در صورت وجود)
sudo sed -i 's/^interface=.*/#&/' /etc/dnsmasq.conf
sudo sed -i 's/^dhcp-range=.*/#&/' /etc/dnsmasq.conf

# اضافه کردن جدید
sudo tee -a /etc/dnsmasq.conf << 'EOF'

#####################################
# Custom DHCP for camera network
interface=eth0
bind-interfaces
dhcp-range=192.168.100.50,192.168.100.100,12h
# اجازه دادن به همه‌ی مک‌ها
dhcp-ignore=tag:!known
#####################################
EOF

# ——————————————————————————————————————
# ۷. ری‌استارت سرویس‌های شبکه و dnsmasq
# ——————————————————————————————————————
echo "ری‌استارت dhcpcd و dnsmasq..."
sudo systemctl restart dhcpcd
# منتظر بمون تا eth0 بیاد بالا
sleep 5
sudo systemctl restart dnsmasq

echo "===== تموم شد! ====="
echo "حالا رزبری روی eth0 آی‌پی 192.168.100.1/24 داره و دوربین هر چی وصل بشه (eth0)، DHCP می‌گیره بین 192.168.100.50–100."
echo "پنجره‌ی بعدی: دوربین رو با کابل به eth0 وصل کن و بررسی کن چه آی‌پی گرفته (مثلاً 192.168.100.50)."
