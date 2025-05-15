# پایه: Python 3.9 سبک
FROM python:3.9-slim

# تنظیم میرور برای pip جهت دور زدن تحریم‌ها و آپگرید pip
RUN pip config set global.index-url https://pypi.sharif.edu/simple/ && \
    pip install --upgrade pip

# نصب پیش‌نیازهای سیستمی برای OpenCV، FFmpeg و دسترسی به دوربین
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      cmake \
      libsm6 \
      libxext6 \
      libxrender-dev \
      libatlas-base-dev \
      libhdf5-dev \
      libhdf5-serial-dev \
      libopenblas-dev \
      libgtk-3-dev \
      ffmpeg \
      libavcodec-dev \
      libavformat-dev \
      libswscale-dev \
      libv4l-dev \
    && rm -rf /var/lib/apt/lists/*

# دایرکتوری اپ داخل کانتینر
WORKDIR /app

# کپی کردن فایل‌های پروژه
COPY faceDetectionWithCamera.py /app/
COPY requirements.txt /app/
COPY assets /app/assets
COPY deploy /app/deploy

# ایجاد پوشه‌های ضروری و تنظیم مجوزها
RUN mkdir -p /app/trainer /app/logs && \
    chmod 775 /app/trainer /app/assets /app/logs

# نصب پکیج‌های پایتون
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir persiantools

# متغیرهای محیطی پیش‌فرض
ENV MYSQL_HOST=91.107.165.2 \
    MYSQL_DATABASE=mydatabase \
    MYSQL_USER=user \
    MYSQL_PASSWORD=userpassword \
    REDIS_HOST=91.107.165.2 \
    REDIS_PORT=6379 \
    REDIS_PASSWORD= \
    LOG_LEVEL=INFO \
    PYTHONUNBUFFERED=1

# اکسپوز کردن پورت
EXPOSE 8080

# دستور پیش‌فرض اجرای اسکریپت
CMD ["python", "faceDetectionWithCamera.py"]