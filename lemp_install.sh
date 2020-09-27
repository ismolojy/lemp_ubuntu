#!/usr/bin/env

## Variables ##
mysql_passwd="ismology123"
db_name="mysql"

## Step 1 – Installing the Nginx Web Server ##
apt update
apt install nginx
# Configure UFW
ufw allow 'Nginx HTTP'
ufw allow 'Nginx HTTPS'
ufw enable

## Step 2 – Installing MySQL to Manage Site Data ##
apt install mysql-server -y
mysql -D $db_name -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$mysql_passwd'; FLUSH PRIVILEGES;"

## Step 3 – Installing PHP ##
apt install php-fpm php-mysql -y


## BASH вообще не удобен для таких мероприятий ##
## Лучше сделаю через Ansible ##