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
ARG PM_MAX_CHILDREN
ARG PM_START_SERVERS
ARG PM_MIN_SPARE_SERVERS
ARG PM_MAX_SPARE_SERVERS
ARG DATE_TIMEZONE

COPY ./phusion /tmp
RUN chmod -R +x /tmp
COPY ./config /tmp

RUN mkdir /var/www && mkdir /run/php

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php \
    &&  \
    apt-get update \
    && \
    apt-get install -y --no-install-recommends \
        # install and system tools
        wget \
        unzip \
        # minimum requirements
        php7.0-fpm \
        php7.0-mysql \
        php7.0-xml \
        php7.0-gd \
        php7.0-mbstring \
        php7.0-zip \
        php7.0-bz2 \
        php7.0-curl \
    && \
    # install composer
    /tmp/install-composer-debian.sh && mv /composer.phar /usr/local/bin/composer \
    && \
    # recommended
    if ( $USE_RECOMMENDED ); then  apt-get install -y --no-install-recommends php7.0-imagick php7.0-curl; fi \
    && \
    if ( $USE_REDIS ); then  apt-get install -y --no-install-recommends php7.0-redis; fi \
    && \
    if ( $USE_MEMCACHE ); then  apt-get install -y --no-install-recommends php7.0-memcache; fi \
    && \
    # additional
    if ( $USE_ADDITIONAL ); then apt-get install -y --no-install-recommends \
            xz-utils \
            ghostscript \
            wkhtmltopdf \
            html2text \
            xvfb \
            poppler-utils \
            libpng16-16 \
            libimage-exiftool-perl \
            inkscape \
            libreoffice \
        && \
        # ffmpeg
        /tmp/install-ffmpeg.sh \
        && \
        # ZopfliPNG
        wget https://github.com/imagemin/zopflipng-bin/raw/master/vendor/linux/zopflipng -O /usr/local/bin/zopflipng \
            && chmod 0755 /usr/local/bin/zopflipng \
        && \
        # PngCrush
        wget https://github.com/imagemin/pngcrush-bin/raw/master/vendor/linux/pngcrush -O /usr/local/bin/pngcrush \
            && chmod 0755 /usr/local/bin/pngcrush \
        && \
        # JPEGOptim
        wget https://github.com/imagemin/jpegoptim-bin/raw/master/vendor/linux/jpegoptim -O /usr/local/bin/jpegoptim\
            && chmod 0755 /usr/local/bin/jpegoptim \
        && \
        # PNGOut
        wget https://github.com/imagemin/pngout-bin/raw/master/vendor/linux/x64/pngout -O /usr/local/bin/pngout \
            && chmod 0755 /usr/local/bin/pngout \
        && \
        # AdvPNG
        wget https://github.com/imagemin/advpng-bin/raw/master/vendor/linux/advpng -O /usr/local/bin/advpng \
            && chmod 0755 /usr/local/bin/advpng \
        && \
        # mozjpeg /cjepg
        wget https://github.com/imagemin/mozjpeg-bin/raw/master/vendor/linux/cjpeg -O /usr/local/bin/cjpeg \
            && chmod 0755 /usr/local/bin/cjpeg; fi \
    && \
    # config php7.0-fpm to use port 9000 insted of unix socket
    sed -i "/listen =/c\listen = \[\:\:\]\:9000" /etc/php/7.0/fpm/pool.d/www.conf && \
    if ( $LOG_ERROR ); then  sed -i "/error_log =/c\error_log = \/proc\/self\/fd\/2" /etc/php/7.0/fpm/php-fpm.conf; fi && \
    if ( $LOG_ACCESS ); then  sed -i "/;access.log =/c\access.log = \/proc\/self\/fd\/2" /etc/php/7.0/fpm/pool.d/www.conf; fi && \
    # file size configs
    sed -i "/memory_limit =/c\memory_limit = $MEMORY_LIMIT" /etc/php/7.0/fpm/php.ini && \
    sed -i "/memory_limit =/c\memory_limit = $MEMORY_LIMIT" /etc/php/7.0/cli/php.ini && \
    sed -i "/post_max_size =/c\post_max_size = $POST_MAXSIZE" /etc/php/7.0/fpm/php.ini && \
    sed -i "/post_max_size =/c\post_max_size = $POST_MAXSIZE" /etc/php/7.0/cli/php.ini && \
    sed -i "/upload_max_filesize =/c\upload_max_filesize = $UPLOAD_MAX_FILESIZE" /etc/php/7.0/fpm/php.ini && \
    sed -i "/upload_max_filesize =/c\upload_max_filesize = $UPLOAD_MAX_FILESIZE" /etc/php/7.0/cli/php.ini && \
    # php-fpm www.conf process management
    sed -i "/pm.max_children =/c\pm.max_children = $PM_MAX_CHILDREN" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "/pm.start_servers =/c\pm.start_servers = $PM_START_SERVERS" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "/pm.min_spare_servers =/c\pm.min_spare_servers = $PM_MIN_SPARE_SERVERS" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i "/pm.max_spare_servers =/c\pm.max_spare_servers = $PM_MAX_SPARE_SERVERS" /etc/php/7.0/fpm/pool.d/www.conf && \
    # date timezone
    sed -i "/;date.timezone =/c\date.timezone = $DATE_TIMEZONE" /etc/php/7.0/fpm/php.ini && \
    sed -i "/;date.timezone =/c\date.timezone = $DATE_TIMEZONE" /etc/php/7.0/cli/php.ini \
    && \
    chown -R www-data:www-data /var/www \
    && \
    mv /tmp/run.sh /run.sh \
    && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && apt-get autoremove -y

EXPOSE 9000

WORKDIR /var/www

CMD ["/run.sh"]