@echo off
chcp 65001 > nul

echo راه‌اندازی سیستم تشخیص چهره با داکر
echo ===============================

:: بررسی وجود دوربین (در ویندوز نمی‌توان مستقیماً بررسی کرد)
echo در حال بررسی تنظیمات...

set /p USE_CAMERA=آیا می‌خواهید از دوربین استفاده کنید؟ (y/n): 

if /i "%USE_CAMERA%"=="y" (
    set USE_CAMERA=true
    set /p CAMERA_DEVICE=مسیر دستگاه دوربین را وارد کنید (پیش‌فرض: /dev/video0): 
    if "%CAMERA_DEVICE%"=="" set CAMERA_DEVICE=/dev/video0
) else (
    set USE_CAMERA=false
    set CAMERA_DEVICE=/dev/video0
    echo سیستم بدون دوربین اجرا خواهد شد.
)

:: اجرای داکر کامپوز با متغیرهای محیطی مناسب
echo در حال راه‌اندازی سیستم...
set PORT=8080

docker-compose up -d

echo.
echo سیستم تشخیص چهره با موفقیت راه‌اندازی شد.
echo برای مشاهده لاگ‌ها، دستور زیر را اجرا کنید:
echo docker-compose logs -f
echo.

pause