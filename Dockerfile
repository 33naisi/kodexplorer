FROM php:7.3.6-zts-alpine 

#下载安装包
RUN set -x \
 && mkdir -p /usr/src/kodexplorer \
 && curl -o /tmp/kodexplorer.zip http://static.kodcloud.com/update/download/kodexplorer4.45.zip \
 && unzip -d /usr/src/kodexplorer/ /tmp/kodexplorer.zip \
 && rm -rf /tmp/*

#安装依赖包
RUN set -x \
 && apk add --no-cache --update freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
 && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install -j "$(getconf _NPROCESSORS_ONLN)" gd \
 && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev \
 && sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories \
 && apk --update --no-cache add bash

#优化参数
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
 && sed -i "s/max_execution_time = 30/max_execution_time = 3600/" /usr/local/etc/php/php.ini \
 && sed -i "s/max_input_time = 60/max_input_time = 3600/" /usr/local/etc/php/php.ini \
 && sed -i "s/post_max_size = 8M/post_max_size = 150M/" /usr/local/etc/php/php.ini \
 && sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 150M/" /usr/local/etc/php/php.ini \
 && echo 'open_basedir = /var/www/html/:/tmp/' >> /usr/local/etc/php/php.ini \
 && echo -e '<?php\n//分片上传: 每个切片5M,需要php.ini 中upload_max_filesize大于此值\n$GLOBALS['config']['settings']['updloadChunkSize'] = 1024*1024*5;\n//上传并发数量; 推荐15个并发;\n$GLOBALS['config']['settings']['updloadThreads'] = 15;' > /usr/src/kodexplorer/config/setting_user.php

COPY entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh

VOLUME /var/www/html/

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
CMD [ "php", "-S", "0000:80", "-t", "/var/www/html" ]
