#!/bin/sh

# Start apache daemon
httpd -k start &

# https://stackoverflow.com/questions/63595435/install-mysql-on-a-vm-under-alpine
mysqld --user=root --data=/data &> /dev/null &

# Poll for MySQL daemon
while ! mysqladmin ping -h localhost --silent; do
	sleep 1
done

# https://wordpress.org/support/article/creating-database-for-wordpress/#using-the-mysql-client
mysql -e "DROP DATABASE test;"
mysql -e "CREATE DATABASE ${docker_db_name};"
mysql -e "GRANT ALL PRIVILEGES ON ${docker_db_name}.* TO \"${docker_db_user}\"@\"localhost\" IDENTIFIED BY \"${docker_db_pass}\";"
mysql -e "FLUSH PRIVILEGES;"

# Setup shield using spark and answer yes to migration question
yes | php /var/www/localhost/htdocs/$docker_ci_subdir/spark shield:setup

# Initialize database tables
php /var/www/localhost/htdocs/$docker_ci_subdir/spark migrate

# Ownerships
chown -R apache:apache /usr/share/webapps/phpmyadmin /etc/phpmyadmin /var/www/localhost/htdocs

# Permissions
chmod -R 0777 /var/www/localhost/htdocs/*

# Server/framework is ready for interaction
CODEIGNITER_VERSION=$(php /var/www/localhost/htdocs/$docker_ci_subdir/spark env | grep -Eo "v[[:digit:]\.]+")
echo -e "\nCodeIgniter $CODEIGNITER_VERSION ready"

exec sh