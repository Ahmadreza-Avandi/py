#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import subprocess
import platform
import sys

def clear_screen():
    """پاک کردن صفحه نمایش بر اساس سیستم عامل"""
    if platform.system() == "Windows":
        os.system('cls')
    else:
        os.system('clear')

def print_header():
    """نمایش هدر برنامه"""
    print("\n" + "=" * 50)
    print("سیستم تشخیص چهره - راه‌انداز خودکار")
    print("=" * 50 + "\n")

def get_yes_no_input(prompt):
    """دریافت ورودی بله/خیر از کاربر"""
    while True:
        response = input(prompt + " (y/n): ").strip().lower()
        if response in ["y", "yes", "بله", "ب"]:
            return True
        elif response in ["n", "no", "خیر", "خ"]:
            return False
        print("لطفاً y یا n وارد کنید.")

def get_input_with_default(prompt, default):
    """دریافت ورودی با مقدار پیش‌فرض"""
    response = input(f"{prompt} (پیش‌فرض: {default}): ").strip()
    if not response:
        return default
    return response

def main():
    """تابع اصلی برنامه"""
    clear_screen()
    print_header()
    
    # تنظیمات پیش‌فرض
    env_vars = {
        "MYSQL_HOST": "91.107.165.2",
        "MYSQL_DATABASE": "mydatabase",
        "MYSQL_USER": "user",
        "MYSQL_PASSWORD": "your_password",
        "REDIS_HOST": "91.107.165.2",
        "REDIS_PORT": "6379",
        "REDIS_PASSWORD": "your_redis_password",
        "LOG_LEVEL": "INFO",
        "PORT": "8080",
        "USE_CAMERA": "false",
        "CAMERA_DEVICE": "/dev/video0"
    }
    
    # بررسی تنظیمات پیشرفته
    advanced_config = get_yes_no_input("آیا می‌خواهید تنظیمات پیشرفته را تغییر دهید؟")
    
    if advanced_config:
        print("\n--- تنظیمات پایگاه داده MySQL ---")
        env_vars["MYSQL_HOST"] = get_input_with_default("آدرس سرور MySQL", env_vars["MYSQL_HOST"])
        env_vars["MYSQL_DATABASE"] = get_input_with_default("نام پایگاه داده", env_vars["MYSQL_DATABASE"])
        env_vars["MYSQL_USER"] = get_input_with_default("نام کاربری MySQL", env_vars["MYSQL_USER"])
        env_vars["MYSQL_PASSWORD"] = get_input_with_default("رمز عبور MySQL", env_vars["MYSQL_PASSWORD"])
        
        print("\n--- تنظیمات Redis ---")
        env_vars["REDIS_HOST"] = get_input_with_default("آدرس سرور Redis", env_vars["REDIS_HOST"])
        env_vars["REDIS_PORT"] = get_input_with_default("پورت Redis", env_vars["REDIS_PORT"])
        env_vars["REDIS_PASSWORD"] = get_input_with_default("رمز عبور Redis", env_vars["REDIS_PASSWORD"])
        
        print("\n--- تنظیمات عمومی ---")
        env_vars["LOG_LEVEL"] = get_input_with_default("سطح لاگ (DEBUG, INFO, WARNING, ERROR)", env_vars["LOG_LEVEL"])
        env_vars["PORT"] = get_input_with_default("پورت برنامه", env_vars["PORT"])
    
    # تنظیمات دوربین
    print("\n--- تنظیمات دوربین ---")
    use_camera = get_yes_no_input("آیا می‌خواهید از دوربین استفاده کنید؟")
    env_vars["USE_CAMERA"] = "true" if use_camera else "false"
    
    if use_camera:
        env_vars["CAMERA_DEVICE"] = get_input_with_default("مسیر دستگاه دوربین", env_vars["CAMERA_DEVICE"])
    
    # تأیید نهایی
    print("\n--- خلاصه تنظیمات ---")
    for key, value in env_vars.items():
        print(f"{key}: {value}")
    
    if not get_yes_no_input("\nآیا می‌خواهید سیستم را با این تنظیمات راه‌اندازی کنید؟"):
        print("\nعملیات لغو شد.")
        return
    
    # اجرای داکر کامپوز با متغیرهای محیطی
    print("\nدر حال راه‌اندازی سیستم...")
    
    # تنظیم محیط برای اجرای داکر کامپوز
    env = os.environ.copy()
    env.update(env_vars)
    
    try:
        subprocess.run(["docker-compose", "up", "-d"], env=env, check=True)
        print("\nسیستم تشخیص چهره با موفقیت راه‌اندازی شد.")
        print("برای مشاهده لاگ‌ها، دستور زیر را اجرا کنید:")
        print("docker-compose logs -f")
    except subprocess.CalledProcessError as e:
        print(f"\nخطا در راه‌اندازی سیستم: {e}")
    except FileNotFoundError:
        print("\nخطا: داکر کامپوز نصب نشده است. لطفاً ابتدا Docker و Docker Compose را نصب کنید.")

if __name__ == "__main__":
    try:
        main()
        if platform.system() == "Windows":
            input("\nبرای خروج، کلید Enter را فشار دهید...")
    except KeyboardInterrupt:
        print("\n\nعملیات توسط کاربر لغو شد.")
        sys.exit(0)