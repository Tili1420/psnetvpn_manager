#!/bin/bash

echo "🚀 شروع نصب پنل مدیریت..."

# به‌روزرسانی سرور
sudo apt update && sudo apt upgrade -y

# نصب وابستگی‌ها
sudo apt install -y python3 python3-pip nodejs mysql-server docker docker-compose git

# تنظیم دیتابیس
sudo mysql -e "CREATE DATABASE vpn_manager;"
sudo mysql -e "CREATE USER 'vpn_admin'@'localhost' IDENTIFIED BY 'your_secure_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON vpn_manager.* TO 'vpn_admin'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# دانلود پروژه از GitHub و نصب آن
git clone https://github.com/tili1420/psnetvpn_manager.git
cd psnetvpn_manager

# راه‌اندازی محیط مجازی Python
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt

# اجرای پروژه
python manage.py migrate
python manage.py runserver 0.0.0.0:8000

echo "🎉 نصب و اجرای پنل مدیریت با موفقیت انجام شد!"
