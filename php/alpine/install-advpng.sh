#!/bin/sh

# advpng runtime dependency
apk add libstdc++

apk add --virtual build-dependencies-advpng zlib-dev build-base

#mkdir advpng
#cd advpng
# the git repo seems to be broken atm (Nov 14, 2016, configure is missing)
#git clone https://github.com/amadvance/advancecomp.git .
# all releases after 1.20 fail to build with error in libdeflate/crc32.c
wget https://github.com/amadvance/advancecomp/releases/download/v1.20/advancecomp-1.20.tar.gz
tar xzf /advancecomp-1.20.tar.gz
cd advancecomp-1.20
./configure
make
make install
mv /usr/local/bin/advpng /usr/bin/advpng
cd ..
rm -r /advancecomp-1.20
rm advancecomp-1.20.tar.gz
apk del build-dependencies-advpng