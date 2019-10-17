DockerFile for Create Laravel project:

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
#if you create new project
#RUN composer create-project --prefer-dist laravel/laravel blog "5.6.*"
#RUN chmod -R 777 /var/www/html/blog/storage
RUN mkdir /run/php
CMD ["/start.sh"]





Edit  supervisord.conf and set Configuration for your project as per below sample

Command:vim /etc/apache2/sites-available/laravel.conf 

[program:queue]
process_name=%(program_name)s_%(process_num)02d
command=sudo php /var/www/html/blog/artisan queue:work --tries=3 --daemon --queue=test -vvv
user=root
autostart=true
autorestart=true
numprocs=1
redirect_stderr=true
stdout_logfile=/var/www/html/blog/storage/logs/test.log


Edit  laravel.conf and set Configuration for your project as per below sample

Command:vim /etc/supervisord.conf 

 <VirtualHost *:80>
   ServerName  localhost
   ServerAdmin webmaster@localhost
   DocumentRoot /var/www/html/nilesh/athenarepo/public/
 <Directory /var/www/html/nilesh/athenarepo>
    AllowOverride All
 </Directory>
    ErrorLog ${APACHE_LOG_DIR}/v.error.log
    CustomLog ${APACHE_LOG_DIR}/v.access.log combined
  </VirtualHost>

















Configure Redis server for laravel project


Download official image for redis server 

Command:docker pull  redis:5.0.4

Run image for redis server in docker container 

Command:docker run --name red -d  redis:5.0.4

Make note of redis server ip address and port number using below command

Command:Docker inspect red

*red is container name*

























Configure mysql server for laravel project



Download official image for mysql server 

Command:docker pull  mysql:5.7

Run image for mysql server in docker container 

Command:docker run --name sql -v C:\Nilesh\project\athena\db:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=root -d mysql:5.7

Make note of mysql server ip address and port number using below command

Command:docker inspect sql 

*sql  is container name*


Import db in sql server using below instruction

Login in mysql container using below command

                     Command:Docker exec -it sql bash

     Create & Import database as usual ways 













Configure Phpmyadmin for Mysql


Download official image for phpmyadmin 

Command:docker pull phpmyadmin/phpmyadmin

Run image for phpmyadmin  in docker container and link it with mysql server

Command:docker run --name myadmin -d --link sql:db -p 8082:80 phpmyadmin/phpmyadmin 

To view phpmyadmin in your browser use below link

http://localhost:8082

Note:you can use host ip instead of localhost


























Configure Laravel Web Server 

You need go dockerfile directory and then  use  below command to build laravel image 

Command:docker build  laravel . 

Run image for laravel web server  in docker container and link it with mysql and redis server

Command:docker run --name lara -p 8085:80 --link sql:db  --link red:redis  -v  C:\Nilesh\project\athena\souq:/var/www/html/nilesh  -d laravel

Setup configuration of web server using below instruction

Login in laravel container using below command

              Command:Docker exec -it lara bash
            *lara  is container name*

Edit  supervisord.conf and set Configuration for your project as per below sample

              Command:vim /etc/apache2/sites-available/laravel.conf 

              [program:queue]
              process_name=%(program_name)s_%(process_num)02d
             command=sudo php /var/www/html/blog/artisan queue:work --tries=3 --daemon --queue=test -vvv
              user=root
              autostart=true
              autorestart=true
              numprocs=1
              redirect_stderr=true
              stdout_logfile=/var/www/html/blog/storage/logs/test.log

Edit  laravel.conf and set Configuration for your project as per below sample

              Command:vim /etc/supervisord.conf 

               <VirtualHost *:80>
                 ServerName  localhost
                 ServerAdmin webmaster@localhost
                 DocumentRoot /var/www/html/nilesh/athenarepo/public/
               <Directory /var/www/html/nilesh/athenarepo>
                  AllowOverride All 
               </Directory>
                  ErrorLog ${APACHE_LOG_DIR}/v.error.log
                  CustomLog ${APACHE_LOG_DIR}/v.access.log combined
                </VirtualHost>








