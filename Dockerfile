FROM ubuntu:quantal
MAINTAINER dominik.burgdoerfer@gmail.com

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q openssh-server \
    nginx \
    mysql-server \
    php5-fpm \
    php5-mysql \
    supervisor \
    pwgen unzip
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD nginx-wordpress.conf /etc/nginx/sites-available/default
RUN mkdir -p /var/www
RUN wget -nv 'http://de.wordpress.org/wordpress-3.8.1-de_DE.zip' -O /var/www/wordpress.zip
RUN cd /var/www && unzip -q wordpress.zip && rm wordpress.zip && chown www-data:www-data -R wordpress
ADD start.sh /start
ENV TZ Europe/Berlin
EXPOSE 22 80
CMD ["/bin/bash", "/start"]
