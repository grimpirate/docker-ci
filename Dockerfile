# Base image
FROM alpine

# Install requirements for Codeigniter and SQLite
RUN apk add --no-cache apache2 php-apache2 php-pdo php-intl php-dom php-xml php-xmlwriter php-tokenizer php-ctype php-sqlite3 php-session composer sqlite nano tzdata php-simplexml php-mysqli mysql mysql-client phpmyadmin php-fpm php-pdo_mysql
RUN rm -rf /var/cache/apk/*

# Prepare MySQL server
RUN mkdir /run/mysqld
RUN mysql_install_db

# Configure phpmyadmin ownerships
RUN chown -R apache:apache /usr/share/webapps/phpmyadmin
RUN chown -R apache:apache /etc/phpmyadmin

# Setup phpmyadmin for automatic login
RUN sed -i "s/'auth_type'.*/'auth_type'] = 'config';\n\$cfg['Servers'][\$i]['user'] = 'username';\n\$cfg['Servers'][\$i]['password'] = 'password';\n\$cfg['Servers'][\$i]['hide_db'] = 'information_schema';/" /etc/phpmyadmin/config.inc.php
RUN sed -i "s/'AllowNoPassword'.*/'AllowNoPassword'] = true;/" /etc/phpmyadmin/config.inc.php

# Setup timezone (appropriate timezone necessary for Google 2FA)
RUN cp /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone
RUN sed -i "s/;date.timezone =/date.timezone = \"America\/New_York\"/" /etc/php*/php.ini

# Fully qualified ServerName
RUN sed -i "s/#ServerName.*/ServerName 127.0.0.1/" /etc/apache2/httpd.conf
# Enable mod_rewrite in apache (for .htaccess to function correctly)
RUN sed -i "s/#LoadModule rewrite_module/LoadModule rewrite_module/" /etc/apache2/httpd.conf
# AllowOverride All for .htaccess directives to supercede defaults
RUN sed -i "s/AllowOverride None/AllowOverride All/" /etc/apache2/httpd.conf

###################
### CODEIGNITER ###
###################

WORKDIR /var/www/localhost/htdocs

# Clear contents of htdocs
RUN rm -rf *

# Create sub folder
RUN mkdir sub

# Change web folder from /var/www/localhost/htdocs to /var/www/localhost/htdocs/sub/public
RUN sed -i "s/htdocs/htdocs\/sub\/public/" /etc/apache2/httpd.conf

# Composer install codeigniter4 framework
RUN composer require codeigniter4/framework

# Copy files from framework into sub directory
RUN cp -R vendor/codeigniter4/framework/app sub/.
RUN cp -R vendor/codeigniter4/framework/public sub/.

# Use writable at the root level rather than sub level
RUN cp -R vendor/codeigniter4/framework/writable .

# Copy spark and .env file into sub (ignoring phpunit.xml.dist)
RUN cp vendor/codeigniter4/framework/env sub/.env
RUN cp vendor/codeigniter4/framework/spark sub/.

# Modify default app paths to be one level higher
RUN sed -i "s/\/..\/..\/system/\/..\/..\/..\/vendor\/codeigniter4\/framework\/system/" sub/app/Config/Paths.php
RUN sed -i "s/\/..\/..\/writable/\/..\/..\/..\/writable/" sub/app/Config/Paths.php
RUN sed -i "s/\/..\/..\/tests/\/..\/..\/..\/tests/" sub/app/Config/Paths.php

# Modify composer path to be one level higher
RUN sed -i "s/vendor\/autoload.php/..\/vendor\/autoload.php/" sub/app/Config/Constants.php

# Change environment to development
RUN sed -i "s/# CI_ENVIRONMENT = production/CI_ENVIRONMENT = development/" sub/.env

# Set project minimum-stability to dev
RUN composer config minimum-stability dev
RUN composer config prefer-stable true

# Composer install shield (for user administration)
RUN composer require codeigniter4/shield:dev-develop

# Set up database and app configuration
ADD app/Config/Registrar.php sub/app/Config/Registrar.php
ADD app/Commands sub/app/Commands

# Create ci_sessions table
ADD app/Database/Migrations/2023-02-21-213113_CreateCiSessionsTable.php sub/app/Database/Migrations/2023-02-21-213113_CreateCiSessionsTable.php

###################
### CODEIGNITER ###
###################

##############
### CUSTOM ###
##############



##############
### CUSTOM ###
##############

# Modify all directories and files to ensure no permission problems occur during development
RUN chown -R apache:apache *
RUN chmod -R 0777 *

# Copy configure.sh to root to enable runtime configuration
WORKDIR /
ADD configure.sh .
RUN chmod +x configure.sh
# Replace Windows line endings with Unix line endings
RUN sed -i "s/\r//g" configure.sh

# Set up volume into htdocs directory
VOLUME ["/var/www/localhost/htdocs"]

# Run configure.sh
CMD ["./configure.sh"]

# Expose port 80 for external access
EXPOSE 80
