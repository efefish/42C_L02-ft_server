FROM debian:buster

RUN apt-get update && apt-get install -y --no-install-recommends nginx \
    mariadb-server mariadb-client\
    wget \
    ca-certificates \
    php-cgi php-common php-fpm php-pear php-mbstring php-zip \
    php-net-socket php-gd php-xml-util php-gettext php-mysql php-bcmath \
    openssl 

COPY ./srcs/ .

##phpmyadmin
RUN	wget --no-check-certificate https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.tar.gz \
	&& tar -zxvf phpMyAdmin-5.0.4-all-languages.tar.gz \
	&& rm phpMyAdmin-5.0.4-all-languages.tar.gz \
    && mv phpMyAdmin-5.0.4-all-languages /var/www/html/phpmyadmin \
	&& cp ./config.inc.php /var/www/html/phpmyadmin

## wordpress
RUN wget --no-check-certificate https://wordpress.org/latest.tar.gz \
	&& tar -zxvf latest.tar.gz \
    && mv wordpress /var/www/html \
    && chown -R www-data:root /var/www/*

## openssl
RUN	mkdir /etc/nginx/ssl \
    && cd /etc/nginx/ssl \
    && openssl req -newkey rsa:4096 \
        -x509 \
            -sha256 \
            -days 3650 \
            -nodes \
            -out example.crt \
            -keyout example.key \
			-subj "/CN=wordpress.com"

## Entrykit
COPY ./srcs/default.tmpl /etc/nginx/sites-available/
RUN wget --no-check-certificate https://github.com/progrium/entrykit/releases/download/v0.4.0/entrykit_0.4.0_Linux_x86_64.tgz \
	&& tar -xvzf entrykit_0.4.0_Linux_x86_64.tgz \
	&& rm entrykit_0.4.0_Linux_x86_64.tgz \
	&& mv entrykit /bin/ \
	&& entrykit --symlink

RUN chmod 774 server_start.sh

ENTRYPOINT ["render", "/etc/nginx/sites-available/default", "--", "./server_start.sh"]
