#!/bin/sh
apk add --virtual build-dependencies-redis php7-dev
mkdir redis
cd redis
git clone https://github.com/phpredis/phpredis.git .
git checkout php7
phpize7
./configure
make
make install
echo "extension=redis.so" | tee /etc/php7/conf.d/redis.ini
cd ..
rm -r redis
apk del build-dependencies-redis
