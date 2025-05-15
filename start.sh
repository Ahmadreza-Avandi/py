#!/bin/bash

# اسکریپت راه‌اندازی سیستم تشخیص چهره با داکر

# بررسی وجود دوربین
if [ -e /dev/video0 ]; then
    echo "دوربین یافت شد: /dev/video0"
    USE_CAMERA=true
    CAMERA_DEVICE=/dev/video0
else
    echo "دوربین یافت نشد. سیستم بدون دوربین اجرا خواهد شد."
    USE_CAMERA=false
    CAMERA_DEVICE=/dev/video0
fi

# اجرای داکر کامپوز با متغیرهای محیطی مناسب
USE_CAMERA=$USE_CAMERA CAMERA_DEVICE=$CAMERA_DEVICE docker-compose up -d

echo "سیستم تشخیص چهره با موفقیت راه‌اندازی شد."
echo "برای مشاهده لاگ‌ها، دستور زیر را اجرا کنید:"
echo "docker-compose logs -f"