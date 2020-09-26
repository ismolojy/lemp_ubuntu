#!/usr/bin/env

## Variables ##
$mysql_passwd = "ismology12"

## Step 1 – Installing the Nginx Web Server ##
apt update
apt install nginx
# Configure UFW
ufw allow 'Nginx HTTP'
ufw allow 'Nginx HTTPS'
ufw enable

## Step 2 – Installing MySQL to Manage Site Data ##
apt install mysql-server mysql-client -y
mysql > << EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$mysql_passwd';
FLUSH PRIVILEGES;
EOF

mysql -D mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'ismology12';"
FLUSH PRIVILEGES;

