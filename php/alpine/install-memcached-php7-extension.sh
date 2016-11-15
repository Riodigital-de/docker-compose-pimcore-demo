#!/bin/sh
apk add --virtual build-dependencies-memcached \
    zlib-dev libmemcached-dev cyrus-sasl-dev php7-dev 
mkdir memcached
cd memcached
git clone https://github.com/php-memcached-dev/php-memcached.git .
git checkout php7
phpize7
# --disable-memcached-sasl is currently (November 11, 2016) not working, see https://github.com/php-memcached-dev/php-memcached/issues/276
#./configure --disable-memcached-sasl
# temporary workaround by installing cyrus-sasl-dev
./configure
make
make install
echo "extension=memcached.so" | tee /etc/php7/conf.d/memcached.ini
cd ..
rm -r memcached
apk del build-dependencies-memcached

