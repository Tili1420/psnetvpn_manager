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

# تنظیم پایگاه داده (Database)
sudo mysql -e "CREATE DATABASE IF NOT EXISTS vpn_manager;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'vpn_admin'@'localhost' IDENTIFIED BY 'your_secure_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON vpn_manager.* TO 'vpn_admin'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

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

# بررسی وجود `requirements.txt`
if [ ! -f requirements.txt ]; then
    echo "⚠️ فایل requirements.txt یافت نشد. ایجاد فایل..."
    echo -e "Django==4.2\nrequests\nflask\nnumpy\npandas" > requirements.txt
fi

pip install --upgrade pip
pip install -r requirements.txt

# اجرای مهاجرت دیتابیس
python3 manage.py migrate

# اجرای سرور Django
python3 manage.py runserver 0.0.0.0:8000 &

echo "🎉 نصب و اجرای پنل مدیریت با موفقیت انجام شد! 🚀"
