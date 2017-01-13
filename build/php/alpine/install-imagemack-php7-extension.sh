#!/bin/sh
#apk update
#apk add wget ca-certificates
#update-ca-certificates

## Imagemagick dependency
apk add imagemagick
## imagemagick build dependencies
apk add --virtual build-dependencies-imagemagick \
    imagemagick-dev libmagic php7-dev

ln -s /usr/bin/php7 /usr/bin/php
ln -s /usr/bin/php-config7 /usr/bin/php-config
wget https://github.com/mkoppanen/imagick/archive/phpseven.zip
unzip phpseven.zip
cd imagick-phpseven
phpize7
./configure
make
make install
echo "extension=imagick.so" | tee /etc/php7/conf.d/imagick.ini
cd ..
rm phpseven.zip
apk del build-dependencies-imagemagick
# after this php7-fpm -i reports imagemagick extension is available


