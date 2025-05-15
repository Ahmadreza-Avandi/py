# راهنمای استفاده از داکر برای سیستم تشخیص چهره

این راهنما شامل دستورالعمل‌های لازم برای ساخت و اجرای کانتینر داکر برای سیستم تشخیص چهره است.

## مشکلات رفع شده

- مشکل دسترسی به سرور PyPI شریف با استفاده از میرور رسمی PyPI حل شده است.
- وابستگی‌های پکیج‌ها به‌روزرسانی شده‌اند تا سازگاری بیشتری داشته باشند.
- مشکلات امنیتی مربوط به ذخیره رمزهای عبور در Dockerfile برطرف شده است.

## ساخت تصویر داکر

برای ساخت تصویر داکر، دستور زیر را در پوشه اصلی پروژه اجرا کنید:

```bash
docker build -t face-attendance .
```

## اجرای کانتینر

برای اجرای کانتینر با تنظیمات صحیح، از دستور زیر استفاده کنید:

```bash
docker run -d --name face-attendance \
  -e MYSQL_PASSWORD=your_password \
  -e REDIS_PASSWORD=your_redis_password \
  --device /dev/video0:/dev/video0 \
  -p 8080:8080 \
  face-attendance
```

### توضیحات پارامترها

- `--device /dev/video0:/dev/video0`: برای دسترسی به دوربین سیستم
- `-e MYSQL_PASSWORD=your_password`: تنظیم رمز عبور MySQL
- `-e REDIS_PASSWORD=your_redis_password`: تنظیم رمز عبور Redis
- `-p 8080:8080`: انتشار پورت 8080 برای دسترسی به وب‌سرویس

## عیب‌یابی

### مشکل دسترسی به دوربین

اگر با مشکل دسترسی به دوربین مواجه شدید، مطمئن شوید که:

1. دستگاه دوربین به سیستم متصل است
2. پارامتر `--device` به درستی تنظیم شده است
3. کاربر داکر دسترسی لازم به دستگاه دوربین را دارد

### مشکل اتصال به دیتابیس

اگر با مشکل اتصال به دیتابیس مواجه شدید:

1. مطمئن شوید که آدرس IP و پورت دیتابیس صحیح است
2. رمز عبور را به درستی تنظیم کرده‌اید
3. فایروال سیستم اجازه اتصال به دیتابیس را می‌دهد

## استفاده از docker-compose

برای راه‌اندازی آسان‌تر، می‌توانید از docker-compose استفاده کنید. یک فایل `docker-compose.yml` با محتوای زیر ایجاد کنید:

```yaml
version: '3'

services:
  face-attendance:
    build: .
    container_name: face-attendance
    environment:
      - MYSQL_HOST=91.107.165.2
      - MYSQL_DATABASE=mydatabase
      - MYSQL_USER=user
      - MYSQL_PASSWORD=your_password
      - REDIS_HOST=91.107.165.2
      - REDIS_PORT=6379
      - REDIS_PASSWORD=your_redis_password
      - LOG_LEVEL=INFO
    devices:
      - /dev/video0:/dev/video0
    ports:
      - "8080:8080"
    restart: unless-stopped
```

سپس با دستور زیر کانتینر را اجرا کنید:

```bash
docker-compose up -d
```

برای مشاهده لاگ‌ها:

```bash
docker-compose logs -f
```