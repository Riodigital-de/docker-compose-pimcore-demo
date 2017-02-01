# the goal here is to avoid using the testing repository and build missing extension ourselves
FROM alpine:edge

ARG USE_MEMCACHE
ARG USE_REDIS
ARG USE_RECOMMENDED
ARG USE_ADDITIONAL
ARG LOG_ERROR
ARG LOG_ACCESS
ARG MEMORY_LIMIT
ARG POST_MAXSIZE
ARG UPLOAD_MAX_FILESIZE
ARG PM_MAX_CHILDREN
ARG PM_START_SERVERS
ARG PM_MIN_SPARE_SERVERS
ARG PM_MAX_SPARE_SERVERS
ARG DATE_TIMEZONE

RUN apk update
RUN apk add wget ca-certificates curl bzip2 unzip
RUN update-ca-certificates

RUN apk add \
    # replacement for ntpdate
    sntpc \
    # php
    php7 \
    php7-ctype \
    php7-session \
    php7-dom \
    php7-fpm \
    php7-json \
    php7-dev \
    php7-gd \
    php7-imap \
    php7-exif \
    php7-intl \
    php7-iconv \
    php7-mcrypt \
    php7-mysqli \
    php7-pdo_mysql \
    php7-sqlite3 \
    php7-session \
    php7-openssl \
    php7-opcache \
    php7-bz2 \
    php7-ldap \
    php7-xml \
    php7-mbstring \
    php7-zip \
    php7-bcmath \
    php7-zlib \
    # composer dependency
    php7-phar \
    php7-curl

# symlink php7 to php so that more tools, like composer, can use it correctly
RUN ln -s /usr/bin/php7 /usr/bin/php

## COMPOSER
COPY ./alpine/install-composer-alpine-edge.sh /tmp/install-composer-alpine-edge.sh
RUN chmod +x /tmp/install-composer-alpine-edge.sh && /tmp/install-composer-alpine-edge.sh
RUN mv composer.phar /usr/bin/composer
RUN chmod +x /usr/bin/composer

COPY ./alpine/install-build-dependencies.sh /tmp/install-build-dependencies.sh
RUN chmod +x /tmp/install-build-dependencies.sh
RUN sh /tmp/install-build-dependencies.sh

## RECOMMENDED
COPY ./alpine/install-imagemack-php7-extension.sh /tmp/install-imagemack-php7-extension.sh
RUN chmod +x /tmp/install-imagemack-php7-extension.sh
RUN if ( $USE_RECOMMENDED ); then sh /tmp/install-imagemack-php7-extension.sh; fi

## CACHING
COPY ./alpine/install-redis3-php7-extension.sh /tmp/install-redis3-php7-extension.sh
RUN chmod +x /tmp/install-redis3-php7-extension.sh
RUN if ( $USE_REDIS ); then  sh /tmp/install-redis3-php7-extension.sh; fi

COPY ./alpine/install-memcached-php7-extension.sh /tmp/install-memcached-php7-extension.sh
RUN chmod +x /tmp/install-memcached-php7-extension.sh
RUN if ( $USE_MEMCACHE ); then sh /tmp/install-memcached-php7-extension.sh; fi

## ADDITIONAL
RUN if ( $USE_ADDITIONAL ); then apk add \
    libxrender \
    # for libfontconfig, not named lib, but is the package for libfontconfig
    fontconfig \
    inkscape \
    ghostscript \
    ffmpeg \
    exiftool \
    poppler-utils \
    html2text \
    libreoffice; fi

RUN if ( $USE_ADDITIONAL ); then apk add --update wkhtmltopdf --repository  http://dl-cdn.alpinelinux.org/alpine/edge/testing; fi

# ZopfliPNG
COPY ./alpine/install-zopflipng.sh /tmp/install-zopflipng.sh
RUN chmod +x /tmp/install-zopflipng.sh
RUN if ( $USE_ADDITIONAL ); then /tmp/install-zopflipng.sh; fi
# PngCrush
RUN if ( $USE_ADDITIONAL ); then apk add pngcrush; fi
# JPEGOptim
COPY ./alpine/install-jpegoptim.sh /tmp/install-jpegoptim.sh
RUN chmod +x /tmp/install-jpegoptim.sh
RUN if ( $USE_ADDITIONAL ); then /tmp/install-jpegoptim.sh; fi
# PNGOut
RUN if ( $USE_ADDITIONAL ); then wget https://github.com/imagemin/pngout-bin/raw/master/vendor/linux/x64/pngout -O /usr/bin/pngout \
    && chmod 0755 /usr/bin/pngout; fi
# AdvPNG
COPY ./alpine/install-advpng.sh /tmp/install-advpng.sh
RUN chmod +x /tmp/install-advpng.sh
RUN if ( $USE_ADDITIONAL ); then /tmp/ainstall-advpng.sh; fi
# MozJPEG
COPY ./alpine/install-mozjpeg.sh /tmp/install-mozjpeg.sh
RUN chmod +x /tmp/mozjpeg.sh
RUN if ( $USE_ADDITIONAL ); then /tmp/install-mozjpeg.sh; fi

# pimcore config files
COPY /config/cache.php /tmp/cache.php
COPY /config/system.php /tmp/system.php

# config php7.0-fpm to use port 9000 insted of unix socket
RUN sed -i "/listen =/c\listen = \[\:\:\]\:9000" /etc/php7/php-fpm.d/www.conf
RUN sed -i "/user =/c\user = www-data" /etc/php7/php-fpm.d/www.conf
RUN sed -i "/group =/c\group = www-data" /etc/php7/php-fpm.d/www.conf

# reroute php access and error log for display in docker log
# we dont configure this for cli, since whoever is logged into a container to use the cli should see the output anyway
RUN if ( $LOG_ERROR ); then  sed -i "/;error_log =/c\error_log = \/proc\/self\/fd\/2" /etc/php7/php-fpm.conf; fi
RUN if ( $LOG_ACCESS ); then  sed -i "/;access.log =/c\access.log = \/proc\/self\/fd\/2" /etc/php7/php-fpm.d/www.conf; fi

# file size configs
RUN sed -i "/memory_limit =/c\memory_limit = $MEMORY_LIMIT" /etc/php7/php.ini
RUN sed -i "/post_max_size =/c\post_max_size = $POST_MAXSIZE" /etc/php7/php.ini
RUN sed -i "/upload_max_filesize =/c\upload_max_filesize = $UPLOAD_MAX_FILESIZE" /etc/php7/php.ini

# php-fpm www.conf process management
RUN sed -i "/pm.max_children =/c\pm.max_children = $PM_MAX_CHILDREN" /etc/php7/php-fpm.d/www.conf
RUN sed -i "/pm.start_servers =/c\pm.start_servers = $PM_START_SERVERS" /etc/php7/php-fpm.d/www.conf
RUN sed -i "/pm.min_spare_servers =/c\pm.min_spare_servers = $PM_MIN_SPARE_SERVERS" /etc/php7/php-fpm.d/www.conf
RUN sed -i "/pm.max_spare_servers =/c\pm.max_spare_servers = $PM_MAX_SPARE_SERVERS" /etc/php7/php-fpm.d/www.conf

# date timezone
RUN sed -i "/;date.timezone =/c\date.timezone = $DATE_TIMEZONE" /etc/php7/php.ini

## CLEANUP
RUN if ( $USE_RECOMMENDED || $USE_ADDITIONAL ); then apk del build-dependencies; fi
RUN rm /var/cache/apk/*

RUN mkdir /var/www

RUN adduser -D -u 1000 www-data
RUN chown -R www-data:www-data /var/www

COPY ./alpine/run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 9000

CMD ["/run.sh"]