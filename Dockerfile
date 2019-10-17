FROM ubuntu:16.04

LABEL author="Nilesh"
LABEL description="Container with Apache2 and php 7.2.8"
LABEL name="Apache2-php7.2.8"

COPY ondrej-php-xenial.list /etc/apt/sources.list.d/ondrej-php-xenial.list
COPY ondrej-php.key /tmp/ondrej-php.key


# Install PHP extensions

RUN apt-key add /tmp/ondrej-php.key && \
	apt update && \
	apt install -y vim supervisor apache2 curl\
	php7.2 \
  php7.2-zip \
  php7.2-curl \
  php7.2-opcache \
  php7.2-gd \
  php7.2-json \
  php7.2-mysql \
  php7.2-pgsql \
  php7.2-sqlite3 \
  php7.2-xml \
  php7.2-bcmath \
  php7.2-mbstring \
  php7.2-soap\
  php7.2-ctype\
  php7.2-intl



# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Put apache config for Laravel
COPY supervisord.conf /etc/supervisord.conf
COPY start.sh start.sh
COPY apache2-laravel.conf /etc/apache2/sites-available/laravel.conf
RUN a2dissite 000-default.conf && a2ensite laravel.conf && a2enmod rewrite

# Change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data


WORKDIR /var/www/html
RUN composer create-project --prefer-dist laravel/laravel blog "5.6.*"

RUN chmod -R 777 /var/www/html/blog/storage

RUN mkdir /run/php

CMD ["/start.sh"]

