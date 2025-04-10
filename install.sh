#!/bin/bash

echo "🚀 شروع نصب پنل مدیریت..."

# به‌روزرسانی سیستم
sudo apt update && sudo apt upgrade -y

# نصب وابستگی‌های اصلی
sudo apt install -y python3 python3-pip python3-venv nodejs mysql-server docker docker-compose git

# بررسی نصب بودن Python
if ! command -v python3 &> /dev/null; then
    echo "⚠️ Python نصب نشده است، در حال نصب..."
    sudo apt install python3 python3-pip -y
fi

# تنظیم پایگاه داده (Database)
sudo mysql -e "CREATE DATABASE IF NOT EXISTS vpn_manager;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'vpn_admin'@'localhost' IDENTIFIED BY 'your_secure_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON vpn_manager.* TO 'vpn_admin'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# دانلود پروژه از GitHub و ورود به دایرکتوری مخزن
cd /root
rm -rf psnetvpn_manager
git clone https://github.com/tili1420/psnetvpn_manager.git
cd psnetvpn_manager

# بررسی وجود `manage.py`
if [ ! -f manage.py ]; then
    echo "❌ فایل manage.py یافت نشد! لطفاً مخزن را بررسی کنید."
    exit 1
fi

# ایجاد محیط مجازی Python
python3 -m venv env
source env/bin/activate

# بررسی وجود `requirements.txt` قبل از نصب وابستگی‌ها
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
else
    echo "⚠️ فایل requirements.txt یافت نشد. وابستگی‌ها به‌صورت دستی نصب شوند."
fi

# اجرای مهاجرت دیتابیس
python3 manage.py migrate

# اجرای سرور Django
python3 manage.py runserver 0.0.0.0:8000

echo "🎉 نصب و اجرای پنل مدیریت با موفقیت انجام شد! 🚀"
