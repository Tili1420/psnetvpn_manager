#!/bin/bash

echo "🚀 شروع نصب پنل مدیریت..."

# بررسی مسیر اجرای اسکریپت
if [ ! -f "$(pwd)/install.sh" ]; then
    echo "❌ خطا: اسکریپت در مسیر نادرستی اجرا شده است!"
    exit 1
fi

# به‌روزرسانی سیستم و نصب وابستگی‌ها
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv nodejs mysql-server docker docker-compose git

# بررسی نصب بودن Python و pip
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

# بررسی نصب `python3-venv`
if ! dpkg -l | grep -qw python3-venv; then
    echo "⚠️ نصب بسته python3-venv ..."
    sudo apt install python3-venv -y
fi

# ایجاد محیط مجازی Python
python3 -m venv env
source env/bin/activate

# بررسی وجود `requirements.txt` قبل از نصب وابستگی‌ها
if [ -f requirements.txt ]; then
    pip install --upgrade pip
    pip install -r requirements.txt
else
    echo "⚠️ فایل requirements.txt یافت نشد. وابستگی‌ها به‌صورت دستی نصب شوند."
fi

# اجرای مهاجرت دیتابیس
python3 manage.py migrate

# بررسی اجرا شدن سرور
python3 manage.py runserver 0.0.0.0:8000 &
sleep 5
if ! curl -s http://localhost:8000 | grep -q "Django"; then
    echo "❌ خطا در اجرای سرور! لطفاً تنظیمات را بررسی کنید."
    exit 1
fi

echo "🎉 نصب و اجرای پنل مدیریت با موفقیت انجام شد! 🚀"
