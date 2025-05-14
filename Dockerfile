# پایه: Python 3.9 سبک
FROM python:3.9-slim

# نصب پیش‌نیازهای سیستمی برای OpenCV و FFmpeg
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libsm6 \
      libxext6 \
      libxrender-dev \
      ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# دایرکتوری اپ داخل کانتینر
WORKDIR /app

# کپی کردن فایل‌های پایتون و دایرکتوری‌های assets و deploy
COPY faceDetectionWithCamera.py /app/
COPY requirements.txt /app/
COPY assets /app/assets
COPY deploy /app/deploy
# اگه فایل‌های دیگه‌ای مثل مدل دارید هم بدید
# COPY trainer /app/trainer

# نصب پکیج‌های پایتون
RUN pip install --no-cache-dir -r requirements.txt

# متغیرهای محیطی پیش‌فرض (قابل اورراید با -e)
ENV MYSQL_HOST=91.107.165.2 \
    MYSQL_DATABASE=mydatabase \
    MYSQL_USER=user \
    MYSQL_PASSWORD=userpassword \
    REDIS_HOST=91.107.165.2 \
    REDIS_PORT=6379 \
    REDIS_PASSWORD= \
    LOG_LEVEL=INFO

# اگر لازم باشه پورت خاصی اکسپوز کنید
# EXPOSE 8080

# دستور پیش‌فرض اجرای اسکریپت
CMD ["python", "faceDetectionWithCamera.py"]
