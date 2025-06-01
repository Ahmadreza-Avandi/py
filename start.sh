#!/usr/bin/env bash
#
# test_camera_connection.sh
#
# این اسکریپت به‌صورت گام‌به‌گام:
#   1. کارت eth0 را بالا می‌آورد (ip link set eth0 up).
#   2. بررسی می‌کند آیا لینک فیزیکی (Link detected) وجود دارد یا خیر.
#   3. اگر لینک برقرار باشد، به‌صورت موقت یک IP استاتیک (192.168.1.50/24) روی eth0 تنظیم می‌کند.
#   4. تلاش می‌کند دوربین با IP=192.168.1.168 را پینگ کند.
#   5. اگر پینگ موفق نبود، سرعت/دوپلکس eth0 را به‌صورت دستی روی 100Mbps Full Duplex می‌بندد و دوباره پینگ می‌گیرد.
#   6. در نهایت،‌ اگر همچنان نتوانست پینگ کند، به‌صورت خودکار FFmpeg را نصب می‌کند و سعی می‌کند استریم RTSP دوربین را باز کند.
#
# قبل از اجرا:
#   - مطمئن شوید که کابل شبکه به‌درستی به eth0 وصل است.
#   - دکمه‌های Link (LEDs) روی درگاه LAN رزبری و دوربین باید نور بدهند.
#
# نکته: آدرس IP استاتیک موقت که انتخاب کرده‌ایم 192.168.1.50/24 است.
#       اگر می‌دانید این IP در شبکه‌ی دوربین قبلاً استفاده شده، آن را به چیزی آزادتر تغییر دهید.
#
# Usage: sudo ./test_camera_connection.sh
#

CAMERA_IP="192.168.1.168"
STATIC_IP="192.168.1.50/24"
NETWORK_PREFIX="192.168.1.0/24"
IFACE="eth0"

echo "========== شروع تست اتصال به دوربین =========="

# ۱. بررسی وجود اینترفیس eth0
echo -e "\n[g1] بررسی وجود کارت شبکه '$IFACE'..."
if ! ip link show "$IFACE" &>/dev/null; then
  echo "خطا: اینترفیس '$IFACE' وجود ندارد. اسامی اینترفیس‌ها را با 'ip link' بررسی کنید."
  exit 1
fi

# ۲. بالا بردن eth0
echo -e "\n[g2] بالا بردن '$IFACE'..."
sudo ip link set "$IFACE" up
sleep 2

# ۳. بررسی وضعیت فیزیکی لینک
echo -e "\n[g3] چک کردن وضعیت فیزیکی لینک با ethtool..."
if ! command -v ethtool &>/dev/null; then
  echo "   ▶ نصب ethtool برای بررسی لینک..."
  sudo apt-get update && sudo apt-get install -y ethtool
fi

LINK_STATUS=$(sudo ethtool "$IFACE" 2>/dev/null | grep "Link detected:" | awk '{print $3}')
if [ "$LINK_STATUS" != "yes" ]; then
  echo "   ▶ لینک فیزیکی برقرار نیست (Link detected: $LINK_STATUS)."
  echo "     • لطفاً کابل شبکه را دوباره وصل کنید یا کابل دیگری امتحان کنید."
  echo "     • اگر دوربین و Pi را مستقیم وصل کرده‌اید، شاید نیاز به کابل کراس باشد."
else
  echo "   ▶ لینک فیزیکی برقرار است (Link detected: yes). می‌رویم سر IP استاتیک..."
fi

# ۴. تنظیم موقت IP استاتیک روی eth0
echo -e "\n[g4] تنظیم IP استاتیک موقت: $STATIC_IP روی '$IFACE'..."
# حذف هر IP قبلی در آنترفیس
sudo ip addr flush dev "$IFACE" 
# افزودن IP جدید
sudo ip addr add "$STATIC_IP" dev "$IFACE"

# بررسی وضعیت بعدی
echo "   ▶ وضعیت جدید رابط شبکه:"
ip addr show "$IFACE" | grep "inet " | awk '{print "      " $2 " -> " $NF}'
echo "   ▶ مسیر (Route) پیش‌فرض را حذف می‌کنیم (در این سناریو نیازی به default gateway نیست):"
sudo ip route del default 2>/dev/null || true

# ۵. آزمایش پینگ اول
echo -e "\n[g5] تست پینگ به دوربین ($CAMERA_IP)..."
ping -c 3 "$CAMERA_IP" &>/dev/null
if [ $? -eq 0 ]; then
  echo "   ▶ پینگ موفق! ارتباط با دوربین برقرار است."
  GOTO_STREAM=true
else
  echo "   ▶ پینگ ناموفق. Network is unreachable یا Destination Host Unreachable."
  GOTO_STREAM=false
fi

# ۶. اگر پینگ اول ناموفق بود، تنظیم سرعت/دوپلکس
if [ "$GOTO_STREAM" = false ]; then
  echo -e "\n[g6] پینگ ناموفق بود. می‌خواهیم سرعت/دوپلکس را به‌صورت دستی تنظیم کنیم..."
  # فرض می‌کنیم دوربین 100Mbps Full Duplex کار می‌کند:
  sudo ethtool -s "$IFACE" speed 100 duplex full autoneg off 2>/dev/null
  sleep 2

  echo "   ▶ وضعیت پس از تنظیم سرعت/دوپلکس:"
  sudo ethtool "$IFACE" | grep -E "Speed|Duplex|Auto-neg"

  echo -e "\n[g7] دوباره تست پینگ به دوربین ($CAMERA_IP)..."
  ping -c 3 "$CAMERA_IP" &>/dev/null
  if [ $? -eq 0 ]; then
    echo "   ▶ حالا پینگ موفق شد! ارتباط با دوربین برقرار است."
    GOTO_STREAM=true
  else
    echo "   ▶ هنوز پینگ موفق نیست."
    GOTO_STREAM=false
  fi
fi

# ۷. اگر تا اینجا نتوانستیم پینگ کنیم، هشدار بدهیم
if [ "$GOTO_STREAM" = false ]; then
  echo -e "\n[g8] ** هشدار ** ارتباط شبکه کامل برقرار نشد."
  echo "   • ممکن است همچنان مشکل فیزیکی (کابل، پورت) یا پیکربندی اتو-نِگُوشِیِشن باشد."
  echo "   • می‌توانید یک بار کابل را جدا و دوباره وصل کنید یا کابل کراس امتحان کنید."
  echo "   • اگر کار نکرد، از یک مبدل USB-Ethernet استفاده کنید تا مطمئن شوید مشکل از پورت LAN رزبری نیست."
fi

# ۸. نصب FFmpeg (در صورت نیاز)
echo -e "\n[g9] نصب FFmpeg اگر نصب نیست..."
if ! command -v ffplay &>/dev/null; then
  sudo apt-get update
  sudo apt-get install -y ffmpeg
else
  echo "   ▶ ffplay از قبل نصب است."
fi

# ۹. تلاش برای وصل به استریم RTSP و نمایش تصویر
echo -e "\n[g10] تلاش برای نمایش استریم RTSP دوربین با ffplay..."
echo "   ▶ آدرس RTSP فرضی: rtsp://$CAMERA_IP:554/stream"
echo "   ▶ (اگر URL دوربین‌تان متفاوت است، آن را جایگزین کنید)"
echo

ffplay "rtsp://$CAMERA_IP:554/stream"

echo -e "\n========== پایان اسکریپت =========="
