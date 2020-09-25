#!/usr/bin/env bash

## Step 1 - Creating SSL Certificate ##
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt

## Output ##
# Country Name (2 letter code) [AU]:US
# State or Province Name (full name) [Some-State]:New York
# Locality Name (eg, city) []:New York City
# Organization Name (eg, company) [Internet Widgits Pty Ltd]:Bouncy Castles, Inc.
# Organizational Unit Name (eg, section) []:Ministry of Water Slides
# Common Name (e.g. server FQDN or YOUR name) []:server_IP_address or domain_name
# Email Address []:admin@domaim.com

##Create a strong Diffie-Hellman group##
##Алгоритм Диффи — Хеллмана позволяет двум сторонам получить общий секретный ключ, используя незащищенный от прослушивания,##
##но защищённый от подмены канал связи.##
openssl dhparam -out /etc/nginx/dhparam.pem 4096

## Step 2 – Configuring Nginx to Use SSL ##
#Creating a Configuration Snippet Pointing to the SSL Key and Certificate
cat >/etc/nginx/snippets/self-signed.conf <<EOF
ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
EOF
#Creating a Configuration Snippet with Strong Encryption Settings
cat >/etc/nginx/snippets/ssl-params.conf <<EOF
ssl_protocols TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_dhparam /etc/nginx/dhparam.pem;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
ssl_ecdh_curve secp384r1; # Requires nginx >= 1.1.0
ssl_session_timeout  10m;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off; # Requires nginx >= 1.5.9
ssl_stapling on; # Requires nginx >= 1.3.7
ssl_stapling_verify on; # Requires nginx => 1.3.7
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
# Disable strict transport security for now. You can uncomment the following
# line if you understand the implications.
# add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
EOF

#Adjusting the Nginx Configuration to Use SSL
cat >/etc/nginx/sites-available/test.avon.market <<EOF
server {
        listen 443 ssl;
        listen [::]:443 ssl;
        include snippets/self-signed.conf;
        include snippets/ssl-params.conf;
        root /var/www/html;
        index index.php index.html index.htm index.nginx-debian.html;
        server_name test.avon.market;

        location / {
                try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        }

        location ~ /\.ht {
                deny all;
        }
}

server {
        listen 80;
        listen [::]:80;

        server_name test.avon.market www.test.avon.market;

        return 301 https://$server_name$request_uri;
}
EOF

## Step 3 – Adjusting the Firewall##
ufw allow 'Nginx Full'
ufw delete allow 'Nginx HTTP'
ufw enable

## Step 4 – Enabling the Changes in Nginx ##
nginx -t
systectl restart nginx

