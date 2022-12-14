# Base image
FROM alpine

# Install requirements for Codeigniter and SQLite
RUN apk add --no-cache apache2 php-apache2 php-pdo php-intl php-dom php-xml php-xmlwriter php-tokenizer php-ctype php-sqlite3 php-session composer sqlite nano tzdata postfix
RUN rm -rf /var/cache/apk/*

# Setup timezone (appropriate timezone necessary for Google 2FA)
RUN cp /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone
RUN sed -i "s/;date.timezone =/date.timezone = \"America\/New_York\"/" /etc/php*/php.ini

# Change web folder from /var/www/localhost/htdocs to /var/www/localhost/ci4/sub/public
RUN sed -i "s/htdocs/ci4\/sub\/public/" /etc/apache2/httpd.conf
# Enable mod_rewrite in apache (for .htaccess to function correctly)
RUN sed -i "s/#LoadModule rewrite_module/LoadModule rewrite_module/" /etc/apache2/httpd.conf
# AllowOverride All for .htaccess directives to supercede defaults
RUN sed -i "s/AllowOverride None/AllowOverride All/" /etc/apache2/httpd.conf

WORKDIR /var/www/localhost
RUN mkdir -p ci4/sub
# Composer install codeigniter4 into ci4 directory
RUN composer require codeigniter4/framework --working-dir=ci4

# Copy files from framework into sub directory
RUN cp -R ci4/vendor/codeigniter4/framework/app ci4/sub/.
RUN cp -R ci4/vendor/codeigniter4/framework/public ci4/sub/.
# Use writable at the root level rather than sub level
RUN cp -R ci4/vendor/codeigniter4/framework/writable ci4/.

# Copy spark and .env file into sub (ignoring phpunit.xml.dist)
RUN cp ci4/vendor/codeigniter4/framework/env ci4/sub/.env
RUN cp ci4/vendor/codeigniter4/framework/spark ci4/sub/.

# Modify default app paths to be one level higher
RUN sed -i "s/\/..\/..\/system/\/..\/..\/..\/vendor\/codeigniter4\/framework\/system/" ci4/sub/app/Config/Paths.php
RUN sed -i "s/\/..\/..\/writable/\/..\/..\/..\/writable/" ci4/sub/app/Config/Paths.php
RUN sed -i "s/\/..\/..\/tests/\/..\/..\/..\/tests/" ci4/sub/app/Config/Paths.php

# Modify composer path to be one level higher
RUN sed -i "s/vendor\/autoload.php/..\/vendor\/autoload.php/" ci4/sub/app/Config/Constants.php

# Modify URLs to not include index.php
RUN sed -i "s/'index.php'/''/" ci4/sub/app/Config/App.php
# Modify timezone
RUN sed -i "s/America\/Chicago/America\/New_York/" ci4/sub/app/Config/App.php

# Change environment to development
RUN sed -i "s/# CI_ENVIRONMENT = production/CI_ENVIRONMENT = development/" ci4/sub/.env
# Change baseURL to localhost
RUN sed -i "s/# app.baseURL = ''/app.baseURL = 'http:\/\/localhost'/" ci4/sub/.env
# Specify SQLite database and driver
Run sed -i "s/# database.default.hostname = localhost/database.default.database = sub.db\ndatabase.default.DBDriver = SQLite3\n\n# database.default.hostname = localhost/" ci4/sub/.env
# Raise error/logging level to max
RUN sed -i "s/# logger.threshold = 4/logger.threshold = 9/" ci4/sub/.env

# Insert username welcome_message
RUN sed -i "s/\"heroe\">/\"heroe\"><p><?= auth()->user()->username ?>:<\/p>/" ci4/sub/app/Views/welcome_message.php
# Custom subheading in welcome_message
RUN sed -i "s/<h1>Go further<\/h1>/<h1>Go further<\/h1><h2><svg xmlns=\"http:\/\/www.w3.org\/2000\/svg\" viewBox=\"0 0 640 512\"><path d=\"M349.9 236.3h-66.1v-59.4h66.1v59.4zm0-204.3h-66.1v60.7h66.1V32zm78.2 144.8H362v59.4h66.1v-59.4zm-156.3-72.1h-66.1v60.1h66.1v-60.1zm78.1 0h-66.1v60.1h66.1v-60.1zm276.8 100c-14.4-9.7-47.6-13.2-73.1-8.4-3.3-24-16.7-44.9-41.1-63.7l-14-9.3-9.3 14c-18.4 27.8-23.4 73.6-3.7 103.8-8.7 4.7-25.8 11.1-48.4 10.7H2.4c-8.7 50.8 5.8 116.8 44 162.1 37.1 43.9 92.7 66.2 165.4 66.2 157.4 0 273.9-72.5 328.4-204.2 21.4.4 67.6.1 91.3-45.2 1.5-2.5 6.6-13.2 8.5-17.1l-13.3-8.9zm-511.1-27.9h-66v59.4h66.1v-59.4zm78.1 0h-66.1v59.4h66.1v-59.4zm78.1 0h-66.1v59.4h66.1v-59.4zm-78.1-72.1h-66.1v60.1h66.1v-60.1z\"\/><\/svg>Dockerfile<\/h2><p>Provided by <a href=\"https:\/\/github.com\/grimpirate\/\" target=\"_blank\">GrimPirate<\/a><\/p>/" ci4/sub/app/Views/welcome_message.php
# Insert logout link in welcome_message
RUN sed -i "s/<\/ul>/\t<li class=\"menu-item hidden\"><?= anchor\('\/logout', 'Logout'\) ?><\/li>\n\t\t<\/ul>/" ci4/sub/app/Views/welcome_message.php

# Create SQLite database for use (gets created in writable directory)
RUN php ci4/sub/spark db:create sub --ext db

# Composer install shield into ci4 directory (for user logins)
RUN composer require codeigniter4/shield:dev-develop --working-dir=ci4

# Setup shield using spark and answer yes to migration question
RUN yes | php ci4/sub/spark shield:setup

# Enable authorization on all routes except login, register, and auth
RUN sed -i "s/\/\/ 'invalidchars',/\/\/ 'invalidchars',\n\t\t\t'session' => \['except' => \['login*', 'register', 'auth\/a\/*'\]\],/" ci4/sub/app/Config/Filters.php

# Composer install Google Two Factor Authentication & QRCode Generator
RUN composer require pragmarx/google2fa --working-dir=ci4
RUN composer require bacon/bacon-qr-code --working-dir=ci4

# Configure Halberd module
RUN mkdir -p ci4/sub/app/Modules
RUN sed -i "s/'register'[[:space:]]\+=>[[:space:]]\+null/'register' => 'Halberd\\\\Authentication\\\\Actions\\\\QRCodeActivator'/" ci4/sub/app/Config/Auth.php
RUN sed -i "s/'login'[[:space:]]\+=>[[:space:]]\+null/'login' => 'Halberd\\\\Authentication\\\\Actions\\\\QRCode2FA'/" ci4/sub/app/Config/Auth.php
RUN sed -i "s/views.\+/views = [\n'action_qrcode_activate_show'  => '\\\\Halberd\\\\Views\\\\qrcode_activate_show',\n'action_qrcode_2fa_verify'  => '\\\\Halberd\\\\Views\\\\qrcode_2fa_verify',/" ci4/sub/app/Config/Auth.php
RUN sed -i "s/'Config',/'Config',\n\t\t'Halberd'     => APPPATH . 'Modules\/halberd\/',/" ci4/sub/app/Config/Autoload.php

# Copy Halberd module
ADD Modules ci4/sub/app/Modules

# Modify all directories and files to ensure no permission problems occur during development
RUN chown -R apache:apache *
RUN chmod -R 0777 *

# Copy configure.sh to root to enable launch of apache httpd daemon
WORKDIR /
ADD configure.sh /
RUN chmod +x configure.sh

# Set up volume into ci4 directory
VOLUME ["/var/www/localhost/ci4"]

# Run configure.sh
CMD ["./configure.sh"]

# Expose port 80 for external access
EXPOSE 80
