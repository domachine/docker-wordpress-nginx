#!/bin/bash

set -e

if [ -f /configured ]; then
  exit 0
fi

sed 's/;daemonize = yes/daemonize = no/' -i /etc/php5/fpm/php-fpm.conf

# Generate unique hashs
sed '0,/put your unique phrase here/s//'"$(pwgen -1 -n -c -s 80)/" \
  /var/www/wordpress/wp-config-sample.php > /var/www/wordpress/wp-config.php
for ((i = 0; i < 7; ++i)); do
  sed '0,/put your unique phrase here/s//'"$(pwgen -1 -n -c -s 80)/" \
    -i /var/www/wordpress/wp-config.php
done
sed 's/database_name_here/wordpress/' \
  -i /var/www/wordpress/wp-config.php
sed 's/username_here/wordpress/' \
  -i /var/www/wordpress/wp-config.php
database_password=$(pwgen -1 -s 12)
sed "s/password_here/$database_password/" \
  -i /var/www/wordpress/wp-config.php
echo "DATABASE_PASSWORD: $database_password"
cat >/etc/mysql/init <<EOF
CREATE database wordpress;
GRANT ALL ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY '$database_password';
EOF
password=$(pwgen -1 -s)
echo -e "$password\n$password"|passwd &>/dev/null
echo "PASSWORD: $password"
date > /configured
exec /usr/bin/supervisord
