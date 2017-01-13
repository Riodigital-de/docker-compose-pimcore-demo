FROM phusion/baseimage

ARG USE_MEMCACHE
ARG USE_REDIS
ARG USE_RECOMMENDED
ARG USE_ADDITIONAL
ARG LOG_ERROR
ARG LOG_ACCESS
ARG MEMORY_LIMIT
ARG POST_MAXSIZE
ARG UPLOAD_MAX_FILESIZE
ARG DATE_TIMEZONE

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php

## System tools
RUN apt-get update

RUN apt-get install -y --no-install-recommends wget unzip

## MINIMUM REQUIREMENTS
RUN apt-get install -y --no-install-recommends php7.0-fpm

RUN apt-get install -y --no-install-recommends php7.0-mysql

# iconv is in common

# xml includes dom and simplexml
RUN apt-get install -y --no-install-recommends php7.0-xml

RUN apt-get install -y --no-install-recommends php7.0-gd

# exif is in common

# fileinfo is in common

RUN apt-get install -y --no-install-recommends php7.0-mbstring

# zlib in zip
RUN apt-get install -y --no-install-recommends php7.0-zip

RUN apt-get install -y --no-install-recommends php7.0-bz2

# openssl included in php7

# opcache installed with php7.0-fpm

# install composer
COPY ./phusion/install-composer-debian.sh /tmp/install-composer.sh
RUN chmod +x /tmp/install-composer.sh && /tmp/install-composer.sh
# even though we run the install script in /tmp, composer.phar will land in root
RUN mv /composer.phar /usr/local/bin/composer

## RECOMMENDED
# from ondrej ppa, defaults to php-imagick, provides wrapper for php5.x - php7.1
RUN if ( $USE_RECOMMENDED ); then  apt-get install -y --no-install-recommends php7.0-imagick; fi

RUN if ( $USE_RECOMMENDED ); then  apt-get install -y --no-install-recommends php7.0-curl; fi

# same deal as with imagick
RUN if ( $USE_REDIS ); then  apt-get install -y --no-install-recommends php7.0-redis; fi

RUN if ( $USE_MEMCACHE ); then  apt-get install -y --no-install-recommends php7.0-memcache; fi

## ADDITIONAL

RUN if ( $USE_ADDITIONAL ); then apt-get install -y --no-install-recommends xz-utils; fi

# statically compiled its 179MB, package without recommends is 249MB
# there are no conditional COPY/ADD statements in docker build yet so copy script in any case
COPY ./phusion/install-ffmpeg.sh /install-ffmpeg.sh
RUN if ( $USE_ADDITIONAL ); then  chmod +x /install-ffmpeg.sh && /install-ffmpeg.sh && rm /install-ffmpeg.sh; fi

# package is 47.6mb build dependency alone is 500mb!
RUN if ( $USE_ADDITIONAL ); then  apt-get install -y --no-install-recommends ghostscript; fi

# 288MB
RUN if ( $USE_ADDITIONAL ); then  apt-get install -y --no-install-recommends wkhtmltopdf; fi

# 289kB
RUN if ( $USE_ADDITIONAL ); then  apt-get install -y --no-install-recommends html2text; fi

# 170 mB
RUN if ( $USE_ADDITIONAL ); then  apt-get install -y --no-install-recommends xvfb; fi

# 10.2 MB
RUN if ( $USE_ADDITIONAL ); then  apt-get install -y --no-install-recommends poppler-utils; fi

# ZopfliPNG
RUN if ( $USE_ADDITIONAL ); then  wget https://github.com/imagemin/zopflipng-bin/raw/master/vendor/linux/zopflipng -O /usr/local/bin/zopflipng \
    && chmod 0755 /usr/local/bin/zopflipng; fi
# PngCrush
RUN if ( $USE_ADDITIONAL ); then  wget https://github.com/imagemin/pngcrush-bin/raw/master/vendor/linux/pngcrush -O /usr/local/bin/pngcrush \
    && chmod 0755 /usr/local/bin/pngcrush; fi
# JPEGOptim
RUN if ( $USE_ADDITIONAL ); then  wget https://github.com/imagemin/jpegoptim-bin/raw/master/vendor/linux/jpegoptim -O /usr/local/bin/jpegoptim\
    && chmod 0755 /usr/local/bin/jpegoptim; fi
# PNGOut
RUN if ( $USE_ADDITIONAL ); then  wget https://github.com/imagemin/pngout-bin/raw/master/vendor/linux/x64/pngout -O /usr/local/bin/pngout \
    && chmod 0755 /usr/local/bin/pngout; fi
# AdvPNG
RUN if ( $USE_ADDITIONAL ); then  wget https://github.com/imagemin/advpng-bin/raw/master/vendor/linux/advpng -O /usr/local/bin/advpng \
    && chmod 0755 /usr/local/bin/advpng; fi
# MozJPEG
RUN if ( $USE_ADDITIONAL ); then  apt-get install -y --no-install-recommends libpng16-16; fi

RUN if ( $USE_ADDITIONAL ); then  wget https://github.com/imagemin/mozjpeg-bin/raw/master/vendor/linux/cjpeg -O /usr/local/bin/cjpeg \
    && chmod 0755 /usr/local/bin/cjpeg; fi

# 51.9 MB
RUN if ( $USE_ADDITIONAL ); then  apt-get install -y --no-install-recommends libimage-exiftool-perl; fi

# 185 MB
RUN if ( $USE_ADDITIONAL ); then  apt-get install -y --no-install-recommends inkscape; fi

# 443 MB
RUN if ( $USE_ADDITIONAL ); then  apt-get install -y --no-install-recommends libreoffice; fi

RUN mkdir /var/www

## php config
# config php7.0-fpm to use port 9000 instead of a unix socket
RUN sed -i "/listen =/c\listen = \[\:\:\]\:9000" /etc/php/7.0/fpm/pool.d/www.conf

# reroute php access and error log for display in docker log
# we dont configure this for cli, since whoever is logged into a container to use the cli will see the output anyway
RUN if ( $LOG_ERROR ); then  sed -i "/error_log =/c\error_log = \/proc\/self\/fd\/2" /etc/php/7.0/fpm/php-fpm.conf; fi
RUN if ( $LOG_ACCESS ); then  sed -i "/;access.log =/c\access.log = \/proc\/self\/fd\/2" /etc/php/7.0/fpm/pool.d/www.conf; fi

# file size configs
RUN sed -i "/memory_limit =/c\memory_limit = $MEMORY_LIMIT" /etc/php/7.0/fpm/php.ini
RUN sed -i "/memory_limit =/c\memory_limit = $MEMORY_LIMIT" /etc/php/7.0/cli/php.ini
RUN sed -i "/post_max_size =/c\post_max_size = $POST_MAXSIZE" /etc/php/7.0/fpm/php.ini
RUN sed -i "/post_max_size =/c\post_max_size = $POST_MAXSIZE" /etc/php/7.0/cli/php.ini
RUN sed -i "/upload_max_filesize =/c\upload_max_filesize = $UPLOAD_MAX_FILESIZE" /etc/php/7.0/fpm/php.ini
RUN sed -i "/upload_max_filesize =/c\upload_max_filesize = $UPLOAD_MAX_FILESIZE" /etc/php/7.0/cli/php.ini

# date timezone
RUN sed -i "/;date.timezone =/c\date.timezone = $DATE_TIMEZONE" /etc/php/7.0/fpm/php.ini
RUN sed -i "/;date.timezone =/c\date.timezone = $DATE_TIMEZONE" /etc/php/7.0/cli/php.ini

EXPOSE 9000

RUN mkdir /run/php

COPY /config/cache.php /tmp/cache.php
COPY /config/system.php /tmp/system.php

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN apt-get autoremove -y

COPY ./phusion/run.sh /run.sh
RUN chmod +x /run.sh

WORKDIR /var/www

CMD ["/run.sh"]