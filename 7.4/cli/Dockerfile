#
# rafutaria-php
#
# alpine: 3.16
# php: 7.4.30
# user-group: 82 www-data
#
FROM php:7.4.30-alpine3.16

LABEL maintainer="nekoimi <nekoimime@gmail.com>"

ENV TZ Asia/Shanghai
ENV EXT_EVENT_VERSION   3.0.8
ENV EXT_SWOOLE_VERSION  4.8.10
ENV WORKSPACE     /workspace

ARG PECL_INSTALL="yaf-3.3.5 yac-2.3.1 yaconf-1.1.2 redis-5.3.7 mongodb-1.13.0 xdebug-3.1.5 xlswriter-1.5.2 mcrypt-1.0.5"
ARG ENABLE_MIRRORS=off

WORKDIR /workspace

# Copy resources
COPY docker-entrypoint.sh                               /docker-entrypoint.sh
COPY docker-entrypoint.d/00-cron-entrypoint.sh          /docker-entrypoint.d/00-cron-entrypoint.sh
COPY docker-entrypoint.d/00-supervisor-entrypoint.sh    /docker-entrypoint.d/00-supervisor-entrypoint.sh
COPY docker-entrypoint.d/00-php-entrypoint.sh           /docker-entrypoint.d/00-php-entrypoint.sh

RUN set -x \
# 切换国内源，可选项
    && if [ "$ENABLE_MIRRORS" = "on" ]; then \
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
    fi \
# install composer
    && php -v \
    && tempDir="$(mktemp -d)" \
    && chown nobody:nobody $tempDir \
    && cd $tempDir \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && composer -V \
# install extension
    && pecl config-set preferred_state stable \
#    && pecl config-set cache_dir $tempDir \
    && apk add --no-cache icu-libs libpq libpng libxpm libjpeg libwebp freetype libevent libmcrypt \
    && apk add --no-cache --virtual .build-php-ext-deps \
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
        openssl-dev \
        libevent-dev \
        libmcrypt-dev \
        postgresql-dev \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql pdo_pgsql intl pcntl gd sockets zip \
    && docker-php-ext-enable opcache \
    && if [ ! -z "$PECL_INSTALL" ]; then \
        for ext in $PECL_INSTALL; do \
            echo "pecl install extension => $ext ..." \
            && pecl install http://pecl.php.net/get/$ext \
            || exit 1; \
            extn=$(echo $ext | awk -F - '{print $1}') \
            && docker-php-ext-enable $extn \
            && php --ri $extn ; \
        done \
    fi \
# ext gd
    && docker-php-ext-configure gd --with-webp-dir=/usr/include/ \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-xpm-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
# swoole
    && printf "yes\nyes\nyes\nyes\nyes\nyes\n\n" | pecl install http://pecl.php.net/get/swoole-$EXT_SWOOLE_VERSION \
    && docker-php-ext-enable swoole \
# event 需要单独安装, 加载顺序滞后
    && pecl install http://pecl.php.net/get/event-$EXT_EVENT_VERSION \
    && docker-php-ext-enable --ini-name zz-event.ini event \
    && pecl clear-cache || echo 'pecl no cache to clean up' \
# remove ext build deps
    && apk del .build-php-ext-deps \
    && rm -rf "$tempDir" \
    && rm -rf /tmp/pear \
        \
# install su-exec
    && apk add --no-cache su-exec \
        \
    && apk add --no-cache tzdata git supervisor \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /etc/supervisor.d \
        \
    && chmod +x /docker-entrypoint.sh \
    && chmod -R +x /docker-entrypoint.d

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

CMD ["/usr/local/bin/php", "-a"]
