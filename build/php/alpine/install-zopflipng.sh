#!/bin/sh

mkdir zopfli
cd zopfli
git clone https://github.com/google/zopfli.git .
make zopflipng
mv ./zopflipng /usr/bin/zopflipng
chmod +x /usr/bin/zopflipng
cd ..
rm -r /zopfli