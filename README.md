سیستم حضور و غیاب با تشخیص چهره روی Raspberry Pi
به این پروژه خوش اومدی! اینجا قراره یه سیستم حضور و غیاب باحال با تشخیص چهره رو روی Raspberry Pi راه‌اندازی کنیم. با داکر کار رو ساده‌تر کردیم و برای دور زدن تحریم‌ها هم از میرورهای ایرانی استفاده می‌کنیم. این راهنما از صفر تا صد همراهته—فقط کافیه قدم به قدم پیش بری!

آنچه در انتظارت است

معرفی سریع: پروژه چیه و چرا جذابه؟  
گام ۱: آماده‌سازی Raspberry Pi با مخازن ایرانی  
گام ۲: نصب داکر بدون دردسر  
گام ۳: تنظیم میرورهای داکر برای دور زدن تحریم‌ها  
گام ۴: ساخت پروژه با داکر  
گام ۵: اجرای سیستم و شروع کار  
نکات طلایی: حل مشکلات و ترفندهای کاربردی


قبل از شروع چی نیاز داری؟

Raspberry Pi: مدل ۴ پیشنهاد می‌شه، با دوربین متصل  
سیستم‌عامل: Raspberry Pi OS (Bullseye یا جدیدتر)  
دسترسی: یا از طریق SSH یا مستقیم با ترمینال Pi  
اینترنت: اگه تحریمی، VPN یا پراکسی رو آماده کن  
فایل‌های پروژه: شامل Dockerfile و (اختیاری) docker-compose.yml


گام ۱: آماده‌سازی مخازن با میرور ایرانی
برای اینکه تحریم‌ها اذیتمون نکنه و دانلودها سریع‌تر بشه، مخازن APT رو به یه سرور ایرانی وصل می‌کنیم.

یه کپی از تنظیمات فعلی نگه دار:
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup


فایل مخازن رو باز کن:
sudo nano /etc/apt/sources.list


این خطوط رو بذار داخلش (یکی رو انتخاب کن):

دانشگاه فردوسی مشهد:deb http://mirror.um.ac.ir/raspbian/raspbian/ bullseye main contrib non-free rpi
deb http://mirror.um.ac.ir/raspberrypi/ bullseye main


دانشگاه شریف:deb http://mirror.sharif.edu/raspbian/raspbian/ bullseye main contrib non-free rpi
deb http://mirror.sharif.edu/raspberrypi/ bullseye main




ذخیره کن و خارج شو (Ctrl+X, Y, Enter).

حالا بروزرسانی کن:
sudo apt update
sudo apt upgrade -y




گام ۲: نصب داکر، ساده و سریع
داکر قلب پروژه‌ست! بیایم نصبش کنیم.
روش اول (پیشنهادی):
با اسکریپت رسمی و میرور:
curl -fsSL https://get.docker.com \
  | sed 's/download.docker.com/mirrors.aliyun.com\/docker-ce/g' \
  | sh

اگه نشد (روش دستی):
sudo apt install -y docker.io
sudo systemctl enable --now docker

بدون sudo کار کن:
sudo usermod -aG docker $USER

بعد یه بار از ترمینال خارج و دوباره وارد شو، یا اینو بزن:
newgrp docker


گام ۳: تنظیم میرورهای داکر
برای اینکه ایمیج‌ها رو سریع و بدون مشکل بکشیم، داکر رو به میرورهای ایرانی وصل می‌کنیم.

فایل تنظیمات رو بساز یا ویرایش کن:
sudo mkdir -p /etc/docker
sudo nano /etc/docker/daemon.json


اینو داخلش بذار:
{
  "registry-mirrors": [
    "https://mirror.docker.ir",
    "https://registry.docker.ir",
    "https://mirrors.aliyun.com"
  ]
}


داکر رو ری‌استارت کن:
sudo systemctl restart docker


چک کن ببین درست کار می‌کنه:
docker info | grep -i "Registry Mirrors" -A2



اگه میرورها رو دیدی، همه‌چیز اوکیه!

گام ۴: ساخت پروژه با داکر
حالا نوبت ساختن پروژه‌ست!

برو توی پوشه پروژه:
cd path/to/faceDetectionWithCamera


ایمیج رو بساز:
docker build -t face-attendance:latest .




یه نکته مهم: توی Dockerfile مطمئن شو که میرور پایتون (pip) تنظیم شده باشه:
RUN pip config set global.index-url https://pypi.sharif.edu/simple/ \
 && pip install --upgrade pip



گام ۵: بالا آوردن سیستم
وقتشه پروژه رو اجرا کنیم!
گزینه ۱: با docker run
docker run -d \
  --name face-attendance \
  -p 8080:8080 \
  -e MYSQL_HOST=91.107.165.2 \
  -e MYSQL_DATABASE=mydb \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=pass \
  -e REDIS_HOST=91.107.165.2 \
  -e REDIS_PORT=6379 \
  --device /dev/video0:/dev/video0 \
  face-attendance:latest


برای دیدن لاگ‌ها:docker logs -f face-attendance



گزینه ۲: با docker-compose
اگه فایل docker-compose.yml داری:
docker-compose up -d

لاگ‌ها رو اینجوری ببین:
docker-compose logs -f


نکات طلایی و ترفندها

پورت رو عوض کن: توی -p می‌تونی پورت دلخواهت رو بذاری (مثلاً -p 80:8080).  
دوربین کار نمی‌کنه؟ توی docker run چک کن --device /dev/video0:/dev/video0 باشه.  
تمیزکاری: اگه چیزی قدیمی مونده، اینا رو بزن:docker rm -f face-attendance
docker rmi face-attendance:latest


تست بدون داکر: اگه خواستی توی محیط مجازی پایتون کار کنی:pip config set global.index-url https://pypi.sharif.edu/simple/




موفق باشی!
اگه سوالی داشتی یا چیزی گیر کرد، بگو تا با هم حلش کنیم. امیدوارم پروژه‌ات حسابی بدرخشه!
