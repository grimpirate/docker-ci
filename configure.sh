#!/bin/sh

httpd -k start &

# https://stackoverflow.com/questions/63595435/install-mysql-on-a-vm-under-alpine
mysqld --user=root --data=/data &> /dev/null &

while ! mysqladmin ping -h localhost --silent; do
	sleep 1
done

# https://wordpress.org/support/article/creating-database-for-wordpress/#using-the-mysql-client
mysql -e 'DROP DATABASE test;'
mysql -e 'CREATE DATABASE codeigniter4;'
mysql -e 'GRANT ALL PRIVILEGES ON codeigniter4.* TO "username"@"localhost" IDENTIFIED BY "password";'
mysql -e 'FLUSH PRIVILEGES;'

# Setup shield using spark and answer yes to migration question
yes | php /var/www/localhost/htdocs/sub/spark shield:setup

# Initialize database tables
php /var/www/localhost/htdocs/sub/spark migrate

# Initial setup
php /var/www/localhost/htdocs/sub/spark setup:initial

exec sh