sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/raspbian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/raspbian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update 


----------------------------------------------- 

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin



سیستم حضور و غیاب با تشخیص چهره روی Raspberry Pi
به این پروژه خوش اومدی! اینجا قراره یه سیستم حضور و غیاب باحال با تشخیص چهره رو روی Raspberry Pi راه‌اندازی کنیم. با داکر کار رو ساده‌تر کردیم و برای دور زدن تحریم‌ها هم از میرورهای ایرانی استفاده می‌کنیم. این راهنما از صفر تا صد همراهته—فقط کافیه قدم‌به‌قدم پیش بری!

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
برای اینکه تحریم‌ها اذیتمون نکنه و دانلودها سریع‌تر بشه، مخازن APT رو به سرورهای ایرانی وصل می‌کنیم.
چرا میرور ایرانی؟

سرعت بیشتر: دانلود از سرورهای داخلی خیلی سریع‌تره تا سرورهای خارجی.  
دور زدن تحریم‌ها: بعضی بسته‌ها به خاطر تحریم‌ها مستقیم قابل دانلود نیستن، میرورها این مشکل رو حل می‌کنن.

چطور تنظیمش کنیم؟

یه کپی از فایل فعلی نگه دار (احتیاط همیشه خوبه!):
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup


فایل مخازن رو باز کن:
sudo nano /etc/apt/sources.list


خطوط زیر رو جایگزین خطوط قبلی کن (یکی رو انتخاب کن):

دانشگاه فردوسی مشهد (مثال عملی):
deb http://mirror.um.ac.ir/raspbian/raspbian/ bullseye main contrib non-free rpi
deb http://mirror.um.ac.ir/raspberrypi/ bullseye main

مثلاً اگه بخوای بسته‌ای مثل python3 نصب کنی، با این میرور خیلی سریع‌تر دانلود می‌شه و تحریم‌ها هم جلوت رو نمی‌گیرن.

دانشگاه شریف (گزینه جایگزین):
deb http://mirror.sharif.edu/raspbian/raspbian/ bullseye main contrib non-free rpi
deb http://mirror.sharif.edu/raspberrypi/ bullseye main

اینم مثل بالایی کار می‌کنه، فقط سرورش فرق داره.



ذخیره کن و خارج شو (Ctrl+X, Y, Enter).

سیستم رو بروزرسانی کن:
sudo apt update
sudo apt upgrade -y


اگه sudo apt update بدون خطا اجرا بشه، یعنی میرورها درست کار می‌کنن!




گام ۲: نصب داکر، ساده و سریع
داکر قلب پروژه‌ست! اینجا با جزئیات بیشتر نصبش می‌کنیم و برای تحریم‌ها هم راه‌حل می‌دیم.
چرا داکر؟

پروژه رو توی یه محیط جداگانه (کانتینر) اجرا می‌کنه و وابستگی‌ها رو ساده‌تر مدیریت می‌کنه.
با میرورها، نصب و دانلودش حتی توی ایران هم راحت می‌شه.

روش اول (پیشنهادی): نصب با اسکریپت و میرور

این دستور رو بزن:
curl -fsSL https://get.docker.com \
  | sed 's/download.docker.com/mirrors.aliyun.com\/docker-ce/g' \
  | sh


توضیح: اسکریپت رسمی داکر رو می‌گیره، ولی به جای سرور اصلی، از میرور علی‌یون (چینی) استفاده می‌کنه که تحریم‌ها رو دور می‌زنه.
مثال: اگه بدون میرور اجرا کنی، ممکنه خطای "Connection timed out" بگیری. با این روش، دانلود سریع و بدون مشکل انجام می‌شه.


چک کن داکر نصب شده:
docker --version

خروجی باید چیزی مثل Docker version 20.10.7 باشه.


روش دوم (دستی): اگه اسکریپت کار نکرد

از مخازن APT نصب کن:
sudo apt install -y docker.io
sudo systemctl enable --now docker


توضیح: این روش مستقیم از مخازن ایرانی که توی گام ۱ تنظیم کردی، داکر رو نصب می‌کنه.
مثال: اگه docker.io دانلود نشد، مطمئن شو که مخازن درست تنظیم شدن (sudo apt update رو دوباره بزن).


چک کن سرویس فعال باشه:
sudo systemctl status docker

باید توی خروجی active (running) رو ببینی.


بدون sudo کار کن
برای راحتی کار:
sudo usermod -aG docker $USER
newgrp docker


مثال: قبل از این دستور، اگه docker ps بزنی، خطای "permission denied" می‌ده. بعدش بدون sudo کار می‌کنه.


گام ۳: تنظیم میرورهای داکر برای دور زدن تحریم‌ها
برای دانلود ایمیج‌های داکر (مثل پایتون یا چیزای دیگه)، باید میرورهای محلی رو تنظیم کنیم.
چرا میرور داکر؟

تحریم‌ها: داکر هاب بعضی وقت‌ها توی ایران بلاک می‌شه.
سرعت: دانلود از ایران خیلی سریع‌تر از سرورهای خارجیه.

چطور تنظیم کنیم؟

فایل تنظیمات داکر رو بساز یا ویرایش کن:
sudo mkdir -p /etc/docker
sudo nano /etc/docker/daemon.json


این کد رو بذار توش:
{
  "registry-mirrors": [
    "https://mirror.docker.ir",
    "https://registry.docker.ir",
    "https://mirrors.aliyun.com"
  ]
}


مثال: بدون میرور، اگه docker pull python:3.9 بزنی، ممکنه خطای "connection refused" بگیری. با این تنظیم، دانلود سریع انجام می‌شه.


داکر رو ری‌استارت کن:
sudo systemctl restart docker


چک کن میرورها کار می‌کنن:
docker info | grep -i "Registry Mirrors" -A3

خروجی باید میرورهایی که تنظیم کردی رو نشون بده.


تست عملی
یه ایمیج ساده بکش:
docker pull hello-world

اگه بدون خطا دانلود شد و با docker run hello-world یه پیام "Hello from Docker!" دیدی، یعنی همه‌چیز درسته!

گام ۴: ساخت پروژه با داکر
حالا پروژه رو می‌سازیم!

برو توی پوشه پروژه:
cd path/to/faceDetectionWithCamera


ایمیج رو بساز:
docker build -t face-attendance:latest .




نکته مهم: توی Dockerfile مطمئن شو که میرور پایتون تنظیم شده:
RUN pip config set global.index-url https://pypi.sharif.edu/simple/ \
 && pip install --upgrade pip


مثال: بدون این خط، نصب پکیج‌هایی مثل opencv-python ممکنه به خاطر تحریم‌ها گیر کنه.



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


لاگ‌ها رو ببین:docker logs -f face-attendance



گزینه ۲: با docker-compose
اگه docker-compose.yml داری:
docker-compose up -d

لاگ‌ها رو اینجوری چک کن:
docker-compose logs -f


نکات طلایی و ترفندها

پورت دلخواه: توی -p می‌تونی پورت رو عوض کنی (مثلاً -p 80:8080).  
دوربین کار نمی‌کنه؟: مطمئن شو --device /dev/video0:/dev/video0 توی دستور باشه.  
تمیزکاری: برای حذف چیزای قدیمی:docker rm -f face-attendance
docker rmi face-attendance:latest


تست بدون داکر: اگه بخوای مستقیم با پایتون کار کنی:pip config set global.index-url https://pypi.sharif.edu/simple/




موفق باشی!
اگه سوالی داشتی یا چیزی گیر کرد، بگو تا باهم حلش کنیم. امیدوارم پروژه‌ات حسابی بدرخشه!
