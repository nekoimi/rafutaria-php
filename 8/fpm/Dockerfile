#
# rafutaria-php
#
# alpine: 3.16
# php: 8.1.7
# nginx: 1.21.6
# user-group: 82 www-data
#
FROM php:8.1.7-fpm-alpine3.16

LABEL maintainer="nekoimi <nekoimime@gmail.com>"

ENV TZ Asia/Shanghai

ENV NGINX_VERSION 1.21.6
ENV NJS_VERSION   0.7.3
ENV PKG_RELEASE   1
ENV EXT_EVENT_VERSION   3.0.8
ENV WORKSPACE     /workspace

ARG PECL_INSTALL="yaf-3.3.5 yac-2.3.1 yaconf-1.1.2 redis-5.3.7 mongodb-1.13.0 xdebug-3.1.5 xlswriter-1.5.2 mcrypt-1.0.5"
ARG ENABLE_MIRRORS=off

WORKDIR /workspace

# Copy resources
COPY docker-entrypoint.sh   /docker-entrypoint.sh
COPY docker-entrypoint.d    /docker-entrypoint.d
COPY nginx/nginx.conf       /etc/nginx/nginx.conf.tpl
COPY nginx/default.conf     /etc/nginx/conf.d/default.conf
COPY supervisor.d           /etc/supervisor.d
COPY index.php              /workspace/public/index.php

RUN set -ex \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update \
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
    && apk add --no-cache --virtual .imagick-runtime-deps imagemagick \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql pdo_pgsql intl pcntl sockets zip bcmath \
    && docker-php-ext-enable opcache \
#    for ext in $PECL_INSTALL; do \
#      pecl install $ext \
#      && docker-php-ext-enable $(echo $ext | awk -F - '{print $1}') \
#    done \
# yaf-3.3.5 yac-2.3.1 yaconf-1.1.2 redis-5.3.7  \
# mongodb-1.13.0 xdebug-3.1.5 xlswriter-1.5.2 mcrypt-1.0.5 \
      \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && pecl install xlswriter \
    && docker-php-ext-enable xlswriter \
    && pecl install mcrypt \
    && docker-php-ext-enable mcrypt \
      \
    # ext imagick
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    # event 需要单独安装, 加载顺序滞后
    && pecl install event-$EXT_EVENT_VERSION \
    && docker-php-ext-enable --ini-name zz-event.ini event \
    && pecl clear-cache \
      \
# install composer
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && composer -V \
        \
# install nginx \
    && apk add --no-cache nginx \
      \
# remove build deps
    && apk del .build-deps \
    && rm -rf /tmp/pear \
# install su-exec
    && apk add --no-cache su-exec \
        \
    && apk add --no-cache tzdata git supervisor \
    && mkdir -p /var/log/supervisor \
        \
    && chmod +x /docker-entrypoint.sh \
    && chmod -R +x /docker-entrypoint.d \
        \
    && mkdir -p /var/log/nginx \
    && chown -R www-data:www-data /var/log/nginx

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
