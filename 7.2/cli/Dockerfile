#
# rafutaria-php
#
# alpine: 3.12
# php: 7.2.34
# user-group: 82 www-data
#
FROM php:7.2.34-alpine3.12

LABEL maintainer="nekoimi <nekoimime@gmail.com>"

ENV TZ Asia/Shanghai
ENV EXT_EVENT_VERSION   3.0.8
ENV EXT_SWOOLE_VERSION  4.8.10
ENV WORKSPACE     /workspace

ARG PECL_INSTALL="yaf-3.3.5 yac-2.3.1 yaconf-1.1.2 redis-5.3.7 mongodb-1.13.0 xdebug-3.1.5 xlswriter-1.5.2 mcrypt-1.0.5"
ARG ENABLE_MIRRORS=off

WORKDIR /workspace

# install composer
COPY --from=composer/composer:2.2.23-bin /composer /usr/local/bin/composer

# Layer 1: 系统运行时依赖
RUN set -ex \
    && if [ "$ENABLE_MIRRORS" = "on" ]; then \
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
    fi \
    && apk add --no-cache icu-libs libpq libpng libxpm libjpeg libwebp freetype libevent libmcrypt \
    && apk add --no-cache su-exec tzdata git supervisor \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /etc/supervisor.d \
    && chmod +x /usr/local/bin/composer \
    && composer -V

# Layer 2: PHP 核心扩展 + PECL 扩展
RUN set -ex \
    && pecl config-set preferred_state stable \
    && apk add --no-cache --virtual .build-php-ext-deps \
        gcc g++ make autoconf libc-dev icu-dev \
        freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev libzip-dev zlib-dev libxpm-dev \
        openssl-dev libevent-dev libmcrypt-dev postgresql-dev \
    && apk add --no-cache --virtual .zip-runtime-deps libzip \
    && apk add --no-cache --virtual .mongodb-runtime-deps zstd \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql pdo_pgsql intl pcntl sockets zip bcmath \
    && docker-php-ext-enable opcache \
    && if [ -n "$PECL_INSTALL" ]; then \
        for ext in $PECL_INSTALL; do \
            echo "pecl install extension => $ext ..." \
            && pecl install http://pecl.php.net/get/$ext \
            || exit 1; \
            extn=$(echo $ext | awk -F - '{print $1}') \
            && docker-php-ext-enable $extn \
            && php --ri $extn; \
        done; \
    fi \
    && docker-php-ext-configure gd --with-webp-dir=/usr/include/ \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-xpm-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && printf "yes\nyes\nyes\nyes\nyes\nyes\n\n" \
        | pecl install http://pecl.php.net/get/swoole-$EXT_SWOOLE_VERSION \
    && docker-php-ext-enable swoole \
    && pecl install http://pecl.php.net/get/event-$EXT_EVENT_VERSION \
    && docker-php-ext-enable --ini-name zz-event.ini event \
    && pecl clear-cache || true \
    && apk del .build-php-ext-deps \
    && rm -rf /tmp/pear

# Layer 3: 入口点脚本
COPY docker-entrypoint.sh                               /docker-entrypoint.sh
COPY docker-entrypoint.d/00-cron-entrypoint.sh          /docker-entrypoint.d/00-cron-entrypoint.sh
COPY docker-entrypoint.d/00-supervisor-entrypoint.sh    /docker-entrypoint.d/00-supervisor-entrypoint.sh
COPY docker-entrypoint.d/00-php-entrypoint.sh           /docker-entrypoint.d/00-php-entrypoint.sh

RUN set -ex \
    && chmod +x /docker-entrypoint.sh \
    && chmod -R +x /docker-entrypoint.d

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

CMD ["/usr/local/bin/php", "-a"]
