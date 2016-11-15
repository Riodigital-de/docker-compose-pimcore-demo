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
ARG DATE_TIMEZONE

COPY ./alpine /tmp
RUN chmod -R +x /tmp
COPY ./config /tmp

RUN apk update \
    && \
    apk add \
    # system tools
    wget \
    ca-certificates \
    curl \
    bzip2 \
    unzip \
    && \
    update-ca-certificates \
    && \
    apk add \
    # replacement for ntpdate
    sntpc \
    # php
    php7 \
    php7-ctype \
    php7-session \
    php7-dom \
    php7-fpm \
    php7-json \
    php7-curl \
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
    && \
    ln -s /usr/bin/php7 /usr/bin/php \
    && \
    /tmp/install-composer-alpine-edge.sh && mv composer.phar /usr/bin/composer \
    && \
    if ( $USE_RECOMMENDED || $USE_ADDITIONAL ); then sh /tmp/install-build-dependencies.sh; fi \
    && \
    if ( $USE_RECOMMENDED ); then sh /tmp/install-imagemack-php7-extension.sh; fi \
    && \
    if ( $USE_RECOMMENDED ); then apk add php7-curl; fi \
    && \
    if ( $USE_REDIS ); then  sh /tmp/install-redis3-php7-extension.sh; fi \
    && \
    if ( $USE_MEMCACHE ); then sh /tmp/install-memcached-php7-extension.sh; fi \
    && \
    if ( $USE_ADDITIONAL ); then apk add \
        libxrender \
        fontconfig \
        inkscape \
        ghostscript \
        ffmpeg \
        exiftool \
        poppler-utils \
        html2text \
        libreoffice; fi \
    && \
    if ( $USE_ADDITIONAL ); then apk add --update wkhtmltopdf --repository  http://dl-cdn.alpinelinux.org/alpine/edge/testing; fi \
    && \
    if ( $USE_ADDITIONAL ); then /tmp/install-zopflipng.sh; fi \
    && \
    if ( $USE_ADDITIONAL ); then apk add pngcrush; fi \
    && \
    if ( $USE_ADDITIONAL ); then /tmp/install-jpegoptim.sh; fi \
    && \
    if ( $USE_ADDITIONAL ); then wget https://github.com/imagemin/pngout-bin/raw/master/vendor/linux/x64/pngout -O /usr/bin/pngout \
        && chmod 0755 /usr/bin/pngout; fi \
    && \
    if ( $USE_ADDITIONAL ); then /tmp/install-advpng.sh; fi \
    && \
    if ( $USE_ADDITIONAL ); then /tmp/install-mozjpeg.sh; fi \
    && \
    sed -i "/listen =/c\listen = \[\:\:\]\:9000" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/user =/c\user = www-data" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/group =/c\group = www-data" /etc/php7/php-fpm.d/www.conf && \
    if ( $LOG_ERROR ); then  sed -i "/;error_log =/c\error_log = \/proc\/self\/fd\/2" /etc/php7/php-fpm.conf; fi && \
    if ( $LOG_ACCESS ); then  sed -i "/;access.log =/c\access.log = \/proc\/self\/fd\/2" /etc/php7/php-fpm.d/www.conf; fi && \
    sed -i "/memory_limit =/c\memory_limit = $MEMORY_LIMIT" /etc/php7/php.ini && \
    sed -i "/post_max_size =/c\post_max_size = $POST_MAXSIZE" /etc/php7/php.ini && \
    sed -i "/upload_max_filesize =/c\upload_max_filesize = $UPLOAD_MAX_FILESIZE" /etc/php7/php.ini && \
    sed -i "/;date.timezone =/c\date.timezone = $DATE_TIMEZONE" /etc/php7/php.ini \
    && \
    if ( $USE_RECOMMENDED || $USE_ADDITIONAL ); then apk del build-dependencies; fi && \
    rm /var/cache/apk/* \
    && \
    mkdir /var/www \
    && \
    adduser -D -u 1000 www-data \
    && \
    chown -R www-data:www-data /var/www \
    && \
    mv /tmp/run.sh /run.sh

EXPOSE 9000

#USER www-data

CMD ["/run.sh"]