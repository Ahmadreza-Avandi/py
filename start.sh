#!/bin/bash

#!/bin/bash

# به‌روزرسانی سیستم
echo "به‌روزرسانی سیستم..."
sudo apt update && sudo apt upgrade -y

# نصب پیش‌نیازها
echo "نصب پیش‌نیازها..."
sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev curl libbz2-dev wget

# دانلود آخرین نسخه پایتون (مثلاً 3.11.6، نسخه را بررسی کنید)
PYTHON_VERSION=3.11.6
echo "دانلود پایتون $PYTHON_VERSION..."
wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz

# استخراج فایل
echo "استخراج فایل..."
tar -xvf Python-$PYTHON_VERSION.tar.xz

# ورود به دایرکتوری
cd Python-$PYTHON_VERSION

# پیکربندی و کامپایل
echo "پیکربندی و کامپایل پایتون..."
./configure --enable-optimizations
make -j$(nproc)

# نصب پایتون
echo "نصب پایتون..."
sudo make altinstall

# پاکسازی
cd ..
rm -rf Python-$PYTHON_VERSION Python-$PYTHON_VERSION.tar.xz

# بررسی نسخه نصب‌شده
echo "نسخه پایتون نصب‌شده:"
python3.11 --version

echo "نصب با موفقیت انجام شد!"
