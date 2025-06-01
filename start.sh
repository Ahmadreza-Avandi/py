#!/usr/bin/env bash
# ----------------------------------------------------
# setup_camera_network_bookworm.sh
#
# - آپدیت مخازن و ارتقای سیستم
# - نصب همه‌ی پکیج‌های Qt5/Wayland مورد نیاز برای cv2.imshow
# - نصب python3-opencv و پکیج‌های Python (opencv-contrib، redis، mysqlclient)
# - نصب dnsmasq و کانفیگ DHCP خیلی سبک برای eth0
# - کانفیگ آی‌پی استاتیک 192.168.100.1/24 روی eth0
# ----------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

echo "🌟 شروع نصب و کانفیگ کامل برای Bookworm..."

############################################################
# ۰) چک اولیه که کاربر root نباشه (اصولاً چون sudo داره)
############################################################
if [ "$EUID" -eq 0 ]; then
  echo "❌ لطفاً این اسکریپت رو با حساب کاربری عادی و با sudo اجرا کن (نه مستقیم با root)."
  exit 1
fi

############################################################
# ۱) بروزرسانی apt و ارتقا
############################################################
echo "🔄 آپدیت و ارتقای سیستم..."
sudo apt update -y
sudo apt upgrade -y

############################################################
# ۲) نصب Qt5/Wayland و وابستگی‌ها (برای cv2.imshow بدون ارور Wayland)
############################################################
echo "🎨 نصب Qt5/Wayland dependencies..."
sudo apt install -y \
    libqt5gui5 \
    libqt5widgets5 \
    libqt5core5a \
    qtwayland5 \
    qml-module-qtquick-controls \
    qml-module-qtquick-controls2 \
    qml-module-qtgraphicaleffects \
    qml-module-qtquick-window2 \
    qml-module-qtquick2 \
    libwayland-client0 \
    libwayland-egl1 \
    libwayland-server0 \
    qt5-qmake \
    qtbase5-dev \
    qtdeclarative5-dev \
    qtbase5-dev-tools \
    qtchooser \
    build-essential \
    pkg-config

############################################################
# ۳) نصب OpenCV (system-wide) و نصب pip-based انجین (داخل virtualenv)
############################################################
echo "📸 نصب python3-opencv (system-wide)..."
sudo apt install -y python3-opencv

# اگر virtualenv داری، داخلش opencv-contrib-python نصب کن
if [ -d "$HOME/py/myenv" ] && [ -f "$HOME/py/myenv/bin/activate" ]; then
  echo "🍃 فعالسازی virtualenv و نصب opencv-contrib-python..."
  source "$HOME/py/myenv/bin/activate"
  pip install --upgrade pip setuptools wheel
  # حذف نسخه‌های قدیمی OpenCV اگر لازم باشه
  pip uninstall -y opencv-python opencv-contrib-python || true
  pip install opencv-contrib-python
  deactivate
else
  echo "🔔 پوشه‌ی myenv پیدا نشد یا داخلش نیستی. اگر virtualenv داری، بعداً فعالش کن و pip install کن."
fi

############################################################
# ۴) نصب redis-server و libmysqlclient-dev و ماژول Python
############################################################
echo "🔌 نصب redis-server و libmysqlclient-dev..."
sudo apt install -y redis-server libmysqlclient-dev python3-dev

if [ -d "$HOME/py/myenv" ] && [ -f "$HOME/py/myenv/bin/activate" ]; then
  echo "🍃 نصب python modules (redis, mysqlclient) داخل virtualenv..."
  source "$HOME/py/myenv/bin/activate"
  pip install redis mysqlclient
  deactivate
else
  echo "🔔 مجدداً: اگر virtualenv داری، داخلش pip install کن: redis و mysqlclient"
fi

############################################################
# ۵) نصب dnsmasq برای DHCP خیلی سبک
############################################################
echo "📡 نصب dnsmasq (برای DHCP روی eth0)..."
sudo apt install -y dnsmasq

############################################################
# ۶) کانفیگ آی‌پی استاتیک eth0 در /etc/dhcpcd.conf
############################################################
echo "📝 بکاپ‌گیری از /etc/dhcpcd.conf..."
sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.backup_camera_bookworm

echo "✂️ حذف خطوط قبلی مربوط به eth0 (اگر وجود داشته)..."
sudo sed -i '/^interface eth0/,+5 d' /etc/dhcpcd.conf

echo "➕ اضافه کردن تنظیم IP استاتیک برای eth0..."
sudo tee -a /etc/dhcpcd.conf > /dev/null << 'EOF'

# -----------------------------
# Static IP configuration for camera network (Bookworm)
interface eth0
static ip_address=192.168.100.1/24
static routers=
static domain_name_servers=
# -----------------------------
EOF

############################################################
# ۷) کانفیگ dnsmasq: غیر فعال کردن کانفیگ‌های قبلی و اضافه کردن range جدید
############################################################
echo "📝 بکاپ‌گیری از /etc/dnsmasq.conf..."
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup_camera_bookworm

echo "✂️ کامنت کردن تنظیمات قبلی interface/dhcp-range در dnsmasq.conf..."
sudo sed -i 's/^\(interface=\|dhcp-range=\)/#&/' /etc/dnsmasq.conf || true

echo "➕ اضافه کردن تنظیمات DHCP جدید برای eth0..."
sudo tee -a /etc/dnsmasq.conf > /dev/null << 'EOF'

#####################################
# Custom DHCP for camera network (Bookworm)
interface=eth0
bind-interfaces
dhcp-range=192.168.100.50,192.168.100.100,12h
# اگر می‌خوای فقط دوربین‌های خاص، MAC خاص بگیرن می‌تونی این رو تغییر بدی
# dhcp-host=<MAC-ADDRESS>,192.168.100.50
#####################################
EOF

############################################################
# ۸) ری‌استارت سرویس‌های شبکه و dnsmasq
############################################################
echo "🔄 ری‌استارت dhcpcd و dnsmasq..."
sudo systemctl restart dhcpcd
sleep 3
sudo systemctl restart dnsmasq

############################################################
# ۹) اطلاع به کاربر و خلاصه
############################################################
echo
echo "✅ همه‌چی نصب و کانفیگ شد!"
echo "✔️ اگه الان دوربین رو با کابل LAN وصل کنی به eth0، باید یه IP بین 192.168.100.50 و 100 بگیره."
echo "✔️ برای چک کردن IP دوربین، بعد از وصل کردن کابل اینو بزن:"
echo "    sudo arp-scan --interface=eth0 --localnet"
echo "  یا"
echo "    arp -a"
echo
echo "✔️ وقتی IP دوربین رو پیدا کردی (مثلاً 192.168.100.50)، می‌تونی پینگ کنی:"
echo "    ping 192.168.100.50"
echo "✔️ بعد برای تست استریم می‌تونی از ffplay یا Python/OpenCV استفاده کنی:"
echo "    sudo apt install -y ffmpeg   # اگر ffplay نداری"
echo "    ffplay tcp://192.168.100.50:807"
echo "  یا توی پایتون:"
echo "    cap = cv2.VideoCapture('tcp://192.168.100.50:807', cv2.CAP_FFMPEG)"
echo

echo "🌈 یالا با این همه کانفیگ، دیگه نباید Network is unreachable ببینی و cv2.imshow هم درست کار می‌کنه!"
echo "🎉 موفق باشی داداش!"
