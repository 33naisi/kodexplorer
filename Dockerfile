FROM php:7.3.6-zts-alpine 

ENV KODEXPLORER_URL="http://static.kodcloud.com/update/download/kodexplorer4.40.zip"

RUN set -x \
 && mkdir -p /usr/src/kodexplorer \
 && sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories \
 && apk --update --no-cache add bash \
 && curl -o /tmp/kodexplorer.zip "$KODEXPLORER_URL" \
 && unzip -d /usr/src/kodexplorer/ /tmp/kodexplorer.zip \
 && rm -rf /tmp/*

RUN set -x \
 && apk add --no-cache --update freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
 && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install -j "$(getconf _NPROCESSORS_ONLN)" gd \
 && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
 && sed -i "s/max_execution_time = 30/max_execution_time = 3600/" /usr/local/etc/php/php.ini \
 && sed -i "s/max_input_time = 60/max_input_time = 3600/" /usr/local/etc/php/php.ini \
 && sed -i "s/post_max_size = 8M/post_max_size = 150M/" /usr/local/etc/php/php.ini \
 && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 150M/" /usr/local/etc/php/php.ini \
 && echo 'open_basedir = /var/www/html/:/tmp/' >> /usr/local/etc/php/php.ini

WORKDIR /var/www/html

COPY entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
CMD [ "php", "-S", "0000:80", "-t", "/var/www/html" ]
