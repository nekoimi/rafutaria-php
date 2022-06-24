#
# rafutaria-php
#
# alpine: 3.10
# php: 7.1.33
# nginx: 1.17.1
# composer: 2.2.14
# user-group: 82 www-data
#
FROM php:7.1.33-alpine3.10

LABEL maintainer="nekoimi <nekoimime@gmail.com>"

ENV TZ Asia/Shanghai

ENV WORKSPACE     /workspace

ARG PECL_INSTALL="yaf-3.3.5 yac-2.3.1 yaconf-1.1.2 redis-5.3.7 mongodb-1.11.1 xdebug-2.9.8 xlswriter-1.5.2"
ARG ENABLE_MIRRORS=off

WORKDIR /workspace

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
    && apk add --no-cache icu-libs libpq libpng libevent libmcrypt \
    && apk add --no-cache --virtual .build-php-ext-deps \
        gcc \
        g++ \
        make \
        autoconf \
        libc-dev \
        icu-dev \
        libjpeg \
        libpng-dev \
        openssl-dev \
        libwebp-dev \
        libevent-dev \
        libmcrypt-dev \
        postgresql-dev \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql intl pcntl gd sockets mcrypt \
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
        # swoole
        && printf "yes\nyes\nyes\nyes\n\n" | pecl install http://pecl.php.net/get/swoole-4.5.11 \
        && docker-php-ext-enable swoole \
        # event 需要单独安装, 加载顺序滞后
        && pecl install http://pecl.php.net/get/event-3.0.8 \
        && docker-php-ext-enable --ini-name zz-event.ini event \
        && pecl clear-cache || echo 'pecl no cache to clean up' ; \
    fi \
    && apk del .build-php-ext-deps \
    && rm -rf "$tempDir" \
    && rm -rf /tmp/pear \
# install tools
        \
    && apk add --no-cache tzdata git supervisor \
    && mkdir -p /var/log/supervisor \
        \
    && apk add --no-cache --virtual .py-pip-deps py2-pip

# Copy resources
COPY docker-entrypoint.sh                               /docker-entrypoint.sh
COPY docker-entrypoint.d/00-cron-entrypoint.sh          /docker-entrypoint.d/00-cron-entrypoint.sh
COPY docker-entrypoint.d/00-supervisor-entrypoint.sh    /docker-entrypoint.d/00-supervisor-entrypoint.sh
COPY docker-entrypoint.d/00-php-entrypoint.sh           /docker-entrypoint.d/00-php-entrypoint.sh

COPY supervisor.d                                       /etc/supervisor.d/event-stdout.ini

# Modify permission
RUN set -x \
    && pip install --no-cache-dir supervisor-stdout \
    && apk del .py-pip-deps \
        \
    && chmod +x /docker-entrypoint.sh \
    && chmod -R +x /docker-entrypoint.d

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

CMD ["/usr/local/bin/php", "-a"]
