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
ENV EXT_EVENT_VERSION   3.0.8
ENV WORKSPACE     /workspace

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
    && if [ "$ENABLE_MIRRORS" = "on" ]; then \
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
    fi \
# install nginx
    && apk add --no-cache nginx \
# install su-exec
    && apk add --no-cache su-exec \
# install tools
    && apk add --no-cache tzdata git supervisor \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /etc/supervisor.d \
# install composer
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && composer -V \
    && rm -f composer-setup.php \
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
        libpng-dev \
        libwebp-dev \
        libzip-dev \
        zlib-dev \
        libxpm-dev \
            \
        openssl-dev \
        libevent-dev \
        libmcrypt-dev \
        postgresql-dev \
        imagemagick-dev \
        libtool \
    && apk add --no-cache --virtual .zip-runtime-deps libzip \
    && apk add --no-cache --virtual .mongodb-runtime-deps zstd \
    && apk add --no-cache --virtual .imagick-runtime-deps imagemagick libgomp \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql pdo_pgsql intl pcntl sockets zip bcmath \
    && docker-php-ext-enable opcache \
# ext gd
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    # yaf
    && pecl install yaf-3.3.5 \
    && docker-php-ext-enable yaf \
    # yac
    && pecl install yac-2.3.1 \
    && docker-php-ext-enable yac \
    # yaconf
    && pecl install yaconf-1.1.2 \
    && docker-php-ext-enable yaconf \
    # redis
    && pecl install redis-5.3.7 \
    && docker-php-ext-enable redis \
    # mongodb
    && pecl install mongodb-1.13.0 \
    && docker-php-ext-enable mongodb \
    # xdebug
    && pecl install xdebug-3.1.5 \
    && docker-php-ext-enable xdebug \
    # xlswriter
    && pecl install xlswriter-1.5.2 \
    && docker-php-ext-enable xlswriter \
    # mcrypt
    && pecl install mcrypt-1.0.5 \
    && docker-php-ext-enable mcrypt \
    # ext imagick
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    # event
    && pecl install event-$EXT_EVENT_VERSION \
    && docker-php-ext-enable --ini-name zz-event.ini event \
    && pecl clear-cache \
    # remove build deps
    && apk del .build-deps \
    && rm -rf /tmp/pear \
# Bring in gettext so we can get `envsubst`
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
        \
    && runDeps="$( \
        scanelf --needed --nobanner /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache $runDeps \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/ \
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
