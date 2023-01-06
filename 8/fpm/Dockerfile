#
# rafutaria-php
#
# php
# nginx
# user-group: 82 www-data
#
FROM php:8.1.7-fpm-alpine3.16

LABEL maintainer="nekoimi <nekoimime@gmail.com>"

ENV TZ Asia/Shanghai

WORKDIR /workspace

# Copy resources
COPY docker-entrypoint.sh   /docker-entrypoint.sh
COPY docker-entrypoint.d    /docker-entrypoint.d
COPY nginx/nginx.conf       /etc/nginx/nginx.conf.tpl
COPY nginx/default.conf     /etc/nginx/conf.d/default.conf
COPY supervisor.d           /etc/supervisor.d
COPY index.php              /workspace/public/index.php

RUN set -ex \
#   && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update \
# install nginx \
    && apk add --no-cache nginx \
        \
# install composer
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && composer -V \
    && rm -f composer-setup.php \
        \
# install su-exec
    && apk add --no-cache su-exec \
        \
# install tools
    && apk add --no-cache tzdata git supervisor \
    && mkdir -p /var/log/supervisor \
        \
# install php extension
    && pecl config-set preferred_state stable \
    && apk add --no-cache icu-libs libpq libpng libxpm libjpeg libwebp freetype libevent libmcrypt \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        g++ \
        make \
        autoconf \
        libc-dev \
        icu-dev \
            \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng \
        libpng-dev \
        jpeg-dev \
        libjpeg \
        libwebp-dev \
        libzip-dev \
        zlib-dev \
        libxpm-dev \
            \
        libevent-dev \
        libmcrypt-dev \
        postgresql-dev \
        imagemagick-dev \
        libtool \
          \
        openssl-dev \
        pcre-dev \
        linux-headers \
        libxslt-dev \
        gd-dev \
        geoip-dev \
        perl-dev \
        libedit-dev \
        mercurial \
        bash \
        alpine-sdk \
        findutils \
    && apk add --no-cache --virtual .zip-runtime-deps libzip \
    && apk add --no-cache --virtual .mongodb-runtime-deps zstd \
    && apk add --no-cache --virtual .imagick-runtime-deps imagemagick libgomp \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql pdo_pgsql intl pcntl sockets zip bcmath \
    && docker-php-ext-enable opcache \
        \
    # redis
    && pecl install redis \
    && docker-php-ext-enable redis \
        \
    # mongodb
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
        \
    # xdebug
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
        \
    # xlswriter
    && pecl install xlswriter \
    && docker-php-ext-enable xlswriter \
        \
    # mcrypt
    && pecl install mcrypt \
    && docker-php-ext-enable mcrypt \
        \
    # ext imagick
    && pecl install imagick \
    && docker-php-ext-enable imagick \
        \
    # event 需要单独安装, 加载顺序滞后
    && pecl install event \
    && docker-php-ext-enable --ini-name zz-event.ini event \
    && pecl clear-cache \
        \
    # remove build deps
    && apk del .build-deps \
    && rm -rf /tmp/pear \
        \
    && chmod +x /docker-entrypoint.sh \
    && chmod -R +x /docker-entrypoint.d \
        \
    && mkdir -p /var/log/nginx \
    && chown -R www-data:www-data /var/log/nginx \
    && chown -R www-data:www-data /var/lib/nginx \
        \
    && chown -R www-data:www-data /workspace

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
