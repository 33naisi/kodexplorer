#!/bin/bash

set -e

if [ "$1" = 'php' ] && [ "$(id -u)" = '0' ]; then
    chown -R www-data /var/www/html
    chmod -R 777 /var/www/html/
fi
if [ ! -e '/var/www/html/index.php' ]; then
    cp -a /usr/src/kodexplorer/* /var/www/html/
    echo -e '<?php\n//分片上传: 每个切片5M,需要php.ini 中upload_max_filesize大于此值\n$GLOBALS['config']['settings']['updloadChunkSize'] = 1024*1024*5;\n//上传并发数量; 推荐15个并发;\n$GLOBALS['config']['settings']['updloadThreads'] = 15;' > /var/www/html/config/setting_user.php
fi

exec "$@"
