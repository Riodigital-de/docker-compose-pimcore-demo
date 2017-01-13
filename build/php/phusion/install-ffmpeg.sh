#!/bin/bash

wget http://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz -O ffmpeg.tar.xz
tar -Jxf ffmpeg*.tar.xz
mv ffmpeg-* /usr/local/ffmpeg
ln -s /usr/local/ffmpeg/ffmpeg /usr/local/bin/
ln -s /usr/local/ffmpeg/ffprobe /usr/local/bin/
ln -s /usr/local/ffmpeg/qt-faststart /usr/local/bin/
ln -s /usr/local/ffmpeg/qt-faststart /usr/local/bin/qtfaststart
