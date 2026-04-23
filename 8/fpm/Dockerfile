#
# rafutaria-php
#
# php: 8.1.7
# nginx: alpine repo
# user-group: 82 www-data
#
FROM php:8.1.7-fpm-alpine3.16

LABEL maintainer="nekoimi <nekoimime@gmail.com>"

ENV TZ Asia/Shanghai
ENV EXT_EVENT_VERSION   3.0.8
ENV WORKSPACE     /workspace

ARG ENABLE_MIRRORS=off

WORKDIR /workspace

# install composer
COPY --from=composer/composer:2.2.23-bin /composer /usr/local/bin/composer

# Layer 1: 系统运行时依赖 + nginx
RUN set -ex \
    && if [ "$ENABLE_MIRRORS" = "on" ]; then \
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
    fi \
    && apk add --no-cache nginx \
    && apk add --no-cache icu-libs libpq libpng libxpm libjpeg libwebp freetype libevent libmcrypt \
    && apk add --no-cache su-exec tzdata git supervisor \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /etc/supervisor.d \
    && chmod +x /usr/local/bin/composer \
    && composer -V

# Layer 2: PHP 核心扩展 + PECL 扩展
RUN set -ex \
    && pecl config-set preferred_state stable \
    && apk add --no-cache --virtual .build-deps \
        gcc g++ make autoconf libc-dev icu-dev \
        freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev libzip-dev zlib-dev libxpm-dev \
        openssl-dev libevent-dev libmcrypt-dev postgresql-dev imagemagick-dev libtool \
    && apk add --no-cache --virtual .zip-runtime-deps libzip \
    && apk add --no-cache --virtual .mongodb-runtime-deps zstd \
    && apk add --no-cache --virtual .imagick-runtime-deps imagemagick libgomp \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql pdo_pgsql intl pcntl sockets zip bcmath \
    && docker-php-ext-enable opcache \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && pecl install yaf-3.3.5 && docker-php-ext-enable yaf \
    && pecl install yac-2.3.1 && docker-php-ext-enable yac \
    && pecl install yaconf-1.1.2 && docker-php-ext-enable yaconf \
    && pecl install redis-5.3.7 && docker-php-ext-enable redis \
    && pecl install mongodb-1.13.0 && docker-php-ext-enable mongodb \
    && pecl install xdebug-3.1.5 && docker-php-ext-enable xdebug \
    && pecl install xlswriter-1.5.2 && docker-php-ext-enable xlswriter \
    && pecl install mcrypt-1.0.5 && docker-php-ext-enable mcrypt \
    && pecl install imagick && docker-php-ext-enable imagick \
    && pecl install event-$EXT_EVENT_VERSION \
    && docker-php-ext-enable --ini-name zz-event.ini event \
    && pecl clear-cache \
    && apk del .build-deps \
    && rm -rf /tmp/pear

# Layer 3: envsubst
RUN set -ex \
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    && runDeps="$( \
        scanelf --needed --nobanner /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache $runDeps \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/

# Layer 4: 入口点脚本和配置 (最常变更，放在最后)
COPY docker-entrypoint.sh   /docker-entrypoint.sh
COPY docker-entrypoint.d    /docker-entrypoint.d
COPY nginx/nginx.conf       /etc/nginx/nginx.conf.tpl
COPY nginx/default.conf     /etc/nginx/conf.d/default.conf
COPY supervisor.d           /etc/supervisor.d
COPY index.php              /workspace/public/index.php

RUN set -ex \
    && chmod +x /docker-entrypoint.sh \
    && chmod -R +x /docker-entrypoint.d \
    && mkdir -p /var/log/nginx \
    && chown -R www-data:www-data /var/log/nginx \
    && chown -R www-data:www-data /var/lib/nginx \
    && chown -R www-data:www-data /workspace

ENTRYPOINT ["/docker-entrypoint.sh"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost/ || exit 1

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
