FROM alpine

RUN apk add --no-cache apache2 php-apache2 php-pdo php-intl php-dom php-xml php-xmlwriter php-tokenizer php-ctype php-sqlite3 composer
RUN rm -rf /var/cache/apk/*

RUN sed -i "s/htdocs/main\/sub\/public/g" /etc/apache2/httpd.conf

WORKDIR /var/www/localhost
RUN mkdir -p main/sub
RUN composer require codeigniter4/framework --working-dir=main

RUN cp -R main/vendor/codeigniter4/framework/app main/sub/.
RUN cp -R main/vendor/codeigniter4/framework/public main/sub/.
RUN cp -R main/vendor/codeigniter4/framework/writable main/.

RUN cp main/vendor/codeigniter4/framework/env main/sub/.env
RUN cp main/vendor/codeigniter4/framework/spark main/sub/.
RUN cp main/vendor/codeigniter4/framework/phpunit.xml.dist main/.

RUN sed -i "s/\/..\/..\/system/\/..\/..\/..\/vendor\/codeigniter4\/framework\/system/g" main/sub/app/Config/Paths.php
RUN sed -i "s/\/..\/..\/writable/\/..\/..\/..\/writable/g" main/sub/app/Config/Paths.php
RUN sed -i "s/\/..\/..\/tests/\/..\/..\/..\/tests/g" main/sub/app/Config/Paths.php

RUN sed -i "s/vendor\/autoload.php/..\/vendor\/autoload.php/g" main/sub/app/Config/Constants.php

RUN sed -i "s/America\/Chicago/America\/New_York/g" main/sub/app/Config/App.php

RUN sed -i "s/# CI_ENVIRONMENT = production/CI_ENVIRONMENT = development/g" main/sub/.env
RUN sed -i "s/# app.baseURL = ''/app.baseURL = 'http:\/\/localhost'/g" main/sub/.env
Run sed -i "s/# database.default.hostname = localhost/database.default.database = sub.db\ndatabase.default.DBDriver = SQLite3\n\n# database.default.hostname = localhost/g" main/sub/.env
RUN sed -i "s/# logger.threshold = 4/logger.threshold = 9/g" main/sub/.env

RUN sed -i "s/<h1>Go further<\/h1>/<h1>Go further<\/h1><h2><svg xmlns=\"http:\/\/www.w3.org\/2000\/svg\" viewBox=\"0 0 640 512\"><path d=\"M349.9 236.3h-66.1v-59.4h66.1v59.4zm0-204.3h-66.1v60.7h66.1V32zm78.2 144.8H362v59.4h66.1v-59.4zm-156.3-72.1h-66.1v60.1h66.1v-60.1zm78.1 0h-66.1v60.1h66.1v-60.1zm276.8 100c-14.4-9.7-47.6-13.2-73.1-8.4-3.3-24-16.7-44.9-41.1-63.7l-14-9.3-9.3 14c-18.4 27.8-23.4 73.6-3.7 103.8-8.7 4.7-25.8 11.1-48.4 10.7H2.4c-8.7 50.8 5.8 116.8 44 162.1 37.1 43.9 92.7 66.2 165.4 66.2 157.4 0 273.9-72.5 328.4-204.2 21.4.4 67.6.1 91.3-45.2 1.5-2.5 6.6-13.2 8.5-17.1l-13.3-8.9zm-511.1-27.9h-66v59.4h66.1v-59.4zm78.1 0h-66.1v59.4h66.1v-59.4zm78.1 0h-66.1v59.4h66.1v-59.4zm-78.1-72.1h-66.1v60.1h66.1v-60.1z\"\/><\/svg>Dockerfile<\/h2><p>Provided by <a href=\"https:\/\/github.com\/grimpirate\/\" target=\"_blank\">GrimPirate<\/a><\/p>/g" main/sub/app/Views/welcome_message.php

RUN php main/sub/spark db:create sub --ext db

RUN chown -R apache:apache *
RUN chmod -R 0777 *

WORKDIR /
ADD configure.sh /
RUN chmod +x configure.sh

VOLUME ["/var/www/localhost/main"]

CMD ["./configure.sh"]

EXPOSE 80
