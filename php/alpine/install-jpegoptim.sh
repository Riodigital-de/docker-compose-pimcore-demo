#!/bin/sh

apk add --virtual build-dependencies-jpegoptim libjpeg-turbo-dev

mkdir jpegoptim
cd jpegoptim
git clone https://github.com/tjko/jpegoptim.git .
./configure
make
make strip
make install
mv /usr/local/bin/jpegoptim /usr/bin/jpegoptim
cd ..
rm -r /jpegoptim
apk del build-dependencies-jpegoptim