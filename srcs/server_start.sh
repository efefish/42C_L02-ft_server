#!/bin/bash

service nginx start

service php7.3-fpm start

service mysql start
mysql -e "CREATE DATABASE wordpress;"
mysql -e "CREATE USER 'wp_user' IDENTIFIED BY 'password';"
mysql -e "GRANT ALL ON wordpress.* TO 'wp_user'@'localhost' IDENTIFIED BY 'password';"

tail -f /dev/null
bash