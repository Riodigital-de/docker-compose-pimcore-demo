#!/bin/sh

mkdir mozjpeg
cd mozjpeg
git clone https://github.com/mozilla/mozjpeg.git .
autoreconf -fiv
./configure
# unfortunately we cant just make cjpeg,
# the build fails*** No rule to make target 'simd/libsimd.la', needed by 'libjpeg.la'.  Stop.
# we have to make all of mozjpeg
make
make install
mv /opt/mozjpeg/bin/cjpeg /usr/bin/cjpeg
cd ..
rm -r /mozjpeg