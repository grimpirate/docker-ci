# Base image
FROM alpine

# Configurable build time variables
ARG db_name=codeigniter4
ARG db_user=username
ARG db_pass=password
ARG db_sessions=ci_sessions
ARG tz_country=America
ARG tz_city=New_York
ARG ci_subdir=sub
ARG ci_baseurl=http://localhost

# Environment variables for docker container (used by configure.sh)
ENV docker_db_name=$db_name
ENV docker_db_user=$db_user
ENV docker_db_pass=$db_pass
# ENV docker_db_sessions=$db_sessions
# ENV docker_tz_country=$tz_country
# ENV docker_tz_city=$tz_city
ENV docker_ci_subdir=$ci_subdir
# ENV docker_ci_baseurl=$ci_baseurl

# Install requirements for Codeigniter, MySQL and SQLite
RUN apk add --no-cache apache2 php-apache2 php-pdo php-intl php-dom php-xml php-xmlwriter php-tokenizer php-ctype php-sqlite3 php-session composer sqlite nano tzdata php-simplexml php-mysqli php-fpm php-pdo_mysql mysql mysql-client phpmyadmin
RUN rm -rf /var/cache/apk/*

# Prepare MySQL server
RUN mkdir /run/mysqld
RUN mysql_install_db

# Setup phpmyadmin for automatic login and hide information_schema database/table(s)
RUN sed -i "s/'auth_type'.*/'auth_type'] = 'config';\n\$cfg['Servers'][\$i]['user'] = '${db_user}';\n\$cfg['Servers'][\$i]['password'] = '${db_pass}';\n\$cfg['Servers'][\$i]['hide_db'] = 'information_schema';/" /etc/phpmyadmin/config.inc.php
RUN sed -i "s/'AllowNoPassword'.*/'AllowNoPassword'] = true;/" /etc/phpmyadmin/config.inc.php
RUN sed -i "s/\/\/\$cfg\['ProtectBinary'\].*/\$cfg['ProtectBinary'] = false;/" /etc/phpmyadmin/config.inc.php

# Setup timezone (appropriate timezone necessary for Google 2FA)
RUN cp /usr/share/zoneinfo/$tz_country/$tz_city /etc/localtime
RUN echo "${tz_country}/${tz_city}" > /etc/timezone
RUN sed -i "s/;date.timezone =/date.timezone = \"${tz_country}\/${tz_city}\"/" /etc/php*/php.ini

# Fully qualified ServerName
RUN sed -i "s/#ServerName.*/ServerName 127.0.0.1/" /etc/apache2/httpd.conf
# Enable mod_rewrite in apache (for .htaccess to function correctly)
RUN sed -i "s/#LoadModule rewrite_module/LoadModule rewrite_module/" /etc/apache2/httpd.conf
# AllowOverride All for .htaccess directives to supercede defaults
RUN sed -i "s/AllowOverride None/AllowOverride All/" /etc/apache2/httpd.conf

# <CodeIgniter 4 Default Setup>

# Change web folder from /var/www/localhost/htdocs to CodeIgniter public folder
RUN sed -i "s/htdocs/htdocs\/${ci_subdir}\/public/" /etc/apache2/httpd.conf

# Copy configure.sh to root to enable runtime configuration
ADD configure.sh .
RUN chmod +x configure.sh
# Replace Windows line endings with Unix line endings
RUN sed -i "s/\r//g" configure.sh

WORKDIR /var/www/localhost/htdocs

# Clear contents of htdocs
RUN rm -rf *

# Create subdirectory
RUN mkdir $ci_subdir

# Composer install CodeIgniter 4 framework
RUN composer require codeigniter4/framework

# Copy files from framework into subdirectory
RUN cp -R vendor/codeigniter4/framework/app $ci_subdir/.
RUN cp -R vendor/codeigniter4/framework/public $ci_subdir/.

# Use writable at the framework level rather than subdirectory level
RUN cp -R vendor/codeigniter4/framework/writable .

# Copy spark and .env file into subdirectory (ignoring phpunit.xml.dist)
RUN cp vendor/codeigniter4/framework/env $ci_subdir/.env
RUN cp vendor/codeigniter4/framework/spark $ci_subdir/.

# Modify default app paths to be one level higher
RUN sed -i "s/\/..\/..\/system/\/..\/..\/..\/vendor\/codeigniter4\/framework\/system/" $ci_subdir/app/Config/Paths.php
RUN sed -i "s/\/..\/..\/writable/\/..\/..\/..\/writable/" $ci_subdir/app/Config/Paths.php
RUN sed -i "s/\/..\/..\/tests/\/..\/..\/..\/tests/" $ci_subdir/app/Config/Paths.php

# Modify composer path to be one level higher
RUN sed -i "s/vendor\/autoload.php/..\/vendor\/autoload.php/" $ci_subdir/app/Config/Constants.php

# Change environment to development
RUN sed -i "s/# CI_ENVIRONMENT = production/CI_ENVIRONMENT = development/" $ci_subdir/.env

# Set project minimum-stability to dev
RUN composer config minimum-stability dev
RUN composer config prefer-stable true

# Composer install shield (for user administration)
RUN composer require codeigniter4/shield:dev-develop

# </CodeIgniter 4 Default Setup>

# <Custom Site Setup>

# Copy all environment variables to .env file
RUN echo "docker.db_name=${db_name}">> $ci_subdir/.env
RUN echo "docker.db_user=${db_user}">> $ci_subdir/.env
RUN echo "docker.db_pass=${db_pass}">> $ci_subdir/.env
RUN echo "docker.db_sessions=${db_sessions}">> $ci_subdir/.env
RUN echo "docker.tz_country=${tz_country}">> $ci_subdir/.env
RUN echo "docker.tz_city=${tz_city}">> $ci_subdir/.env
RUN echo "docker.ci_subdir=${ci_subdir}">> $ci_subdir/.env
RUN echo "docker.ci_baseurl=${ci_baseurl}">> $ci_subdir/.env

# Copy our custom site logic
ADD --chown=apache:apache app $ci_subdir/app
# ADD --chown=apache:apache public $ci_subdir/public

# Modify registration page to remove username field
RUN cp vendor/codeigniter4/shield/src/Views/register.php $ci_subdir/app/Views/register.php
RUN sed -i "s/form-floating mb-4/form-floating mb-4 d-none/" $ci_subdir/app/Views/register.php
RUN sed -i "s/username') ?>\" required/username') ?>\"/" $ci_subdir/app/Views/register.php

# </Custom Site Setup>

# Set up volume into htdocs directory
VOLUME ["/var/www/localhost/htdocs"]

# Run configure.sh
CMD ["/configure.sh"]

# Expose port 80 for external access
EXPOSE 80
