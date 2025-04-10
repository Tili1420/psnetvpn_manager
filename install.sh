#!/bin/bash

echo "🚀 شروع نصب پنل مدیریت..."

# به‌روزرسانی سیستم و نصب وابستگی‌ها
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv nodejs mysql-server docker docker-compose git

# بررسی نصب بودن Python و pip
if ! command -v python3 &> /dev/null; then
    echo "⚠️ Python نصب نشده است، در حال نصب..."
    sudo apt install python3 python3-pip -y
fi

# بررسی وجود دیتابیس قبل از ایجاد آن
DB_EXISTS=$(sudo mysql -e "SHOW DATABASES LIKE 'vpn_manager';" | grep "vpn_manager")
if [ -z "$DB_EXISTS" ]; then
    sudo mysql -e "CREATE DATABASE vpn_manager;"
else
    echo "⚠️ دیتابیس 'vpn_manager' از قبل وجود دارد، ایجاد مجدد لازم نیست!"
fi

# بررسی وجود کاربر قبل از ایجاد آن
USER_EXISTS=$(sudo mysql -e "SELECT User FROM mysql.user WHERE User='vpn_admin';" | grep "vpn_admin")
if [ -z "$USER_EXISTS" ]; then
    sudo mysql -e "CREATE USER 'vpn_admin'@'localhost' IDENTIFIED BY 'your_secure_password';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON vpn_manager.* TO 'vpn_admin'@'localhost';"
    sudo mysql -e "FLUSH PRIVILEGES;"
else
    echo "⚠️ کاربر 'vpn_admin' از قبل وجود دارد، ایجاد مجدد لازم نیست!"
fi

# حذف دایرکتوری مخزن در صورت وجود و کلون مجدد آن
cd /root
if [ -d "psnetvpn_manager" ]; then
    rm -rf psnetvpn_manager
fi
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

# اجرای سرور Django
python3 manage.py runserver 0.0.0.0:8000 &

# بررسی اجرا شدن سرور
sleep 5
if ! curl -s http://localhost:8000 | grep -q "Django"; then
    echo "❌ خطا در اجرای سرور! لطفاً تنظیمات را بررسی کنید."
    exit 1
fi

echo "🎉 نصب و اجرای پنل مدیریت با موفقیت انجام شد! 🚀"
