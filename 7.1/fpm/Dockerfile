#
# rafutaria-php
#
# alpine: 3.10
# php: 7.1.33
# nginx: 1.17.1
# user-group: 82 www-data
#
FROM php:7.1.33-fpm-alpine3.10

LABEL maintainer="nekoimi <nekoimime@gmail.com>"

ENV TZ Asia/Shanghai

ENV NGINX_VERSION       1.17.1
ENV NJS_VERSION         0.3.3
ENV PKG_RELEASE         1
ENV EXT_EVENT_VERSION   3.0.8
ENV WORKSPACE           /workspace

ARG PECL_INSTALL="yaf-3.3.5 yac-2.3.1 yaconf-1.1.2 redis-5.3.7 mongodb-1.11.1 xdebug-2.9.8 xlswriter-1.5.2"
ARG ENABLE_MIRRORS=off

WORKDIR /workspace

# Copy resources
COPY docker-entrypoint.sh   /docker-entrypoint.sh
COPY docker-entrypoint.d    /docker-entrypoint.d
COPY nginx/nginx.conf       /etc/nginx/nginx.conf.tpl
COPY nginx/default.conf     /etc/nginx/conf.d/default.conf
COPY supervisor.d           /etc/supervisor.d
COPY index.php              /workspace/public/index.php

# install composer
COPY --from=composer/composer:2.3.10 /usr/bin/composer /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer && composer -V

RUN set -x \
# 切换国内源，可选项
    && if [ "$ENABLE_MIRRORS" = "on" ]; then \
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
    fi \
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
        libevent-dev \
        libmcrypt-dev \
        postgresql-dev \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql pdo_pgsql intl pcntl sockets mcrypt zip bcmath \
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
# event 需要单独安装, 加载顺序滞后
    && pecl install http://pecl.php.net/get/event-$EXT_EVENT_VERSION \
    && docker-php-ext-enable --ini-name zz-event.ini event \
    && pecl clear-cache || echo 'pecl no cache to clean up' \
# remove ext build deps
    && apk del .build-php-ext-deps \
    && rm -rf "$tempDir" \
    && rm -rf /tmp/pear \
# install nginx
    && apkArch="$(cat /etc/apk/arch)" \
# ============ nginx module ============
# nginx-module-geoip=${NGINX_VERSION}-r${PKG_RELEASE}
# nginx-module-njs=${NGINX_VERSION}.${NJS_VERSION}-r${PKG_RELEASE}
# nginx-module-image-filter=${NGINX_VERSION}-r${PKG_RELEASE}
# nginx-module-xslt=${NGINX_VERSION}-r${PKG_RELEASE}
# ============ nginx module ============
    && nginxPackages=" \
        nginx=${NGINX_VERSION}-r${PKG_RELEASE} \
    " \
    && case "$apkArch" in \
        x86_64) \
# arches officially built by upstream
            set -x \
            && KEY_SHA512="e7fa8303923d9b95db37a77ad46c68fd4755ff935d0a534d26eba83de193c76166c68bfe7f65471bf8881004ef4aa6df3e34689c305662750c0172fca5d8552a *stdin" \
            && apk add --no-cache --virtual .cert-deps \
                openssl \
            && wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
            && if [ "$(openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout | openssl sha512 -r)" = "$KEY_SHA512" ]; then \
                echo "key verification succeeded!"; \
                mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
            else \
                echo "key verification failed!"; \
                exit 1; \
            fi \
            && printf "%s%s%s\n" \
                "https://nginx.org/packages/mainline/alpine/v" \
                `egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release` \
                "/main" \
            | tee -a /etc/apk/repositories \
            && apk del .cert-deps \
            ;; \
        *) \
# we're on an architecture upstream doesn't officially build for
# let's build binaries from the published packaging sources
            set -x \
            && tempDir="$(mktemp -d)" \
            && chown nobody:nobody $tempDir \
            && apk add --no-cache --virtual .build-deps \
                gcc \
                libc-dev \
                make \
                openssl-dev \
                pcre-dev \
                zlib-dev \
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
            && su nobody -s /bin/sh -c " \
                export HOME=${tempDir} \
                && cd ${tempDir} \
                && hg clone https://hg.nginx.org/pkg-oss \
                && cd pkg-oss \
                && hg up ${NGINX_VERSION}-${PKG_RELEASE} \
                && cd alpine \
                && make all \
                && apk index -o ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz ${tempDir}/packages/alpine/${apkArch}/*.apk \
                && abuild-sign -k ${tempDir}/.abuild/abuild-key.rsa ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz \
                " \
            && echo "${tempDir}/packages/alpine/" >> /etc/apk/repositories \
            && cp ${tempDir}/.abuild/abuild-key.rsa.pub /etc/apk/keys/ \
            && apk del .build-deps \
            ;; \
    esac \
    && apk add --no-cache $nginxPackages \
# if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
    && if [ -n "$tempDir" ]; then rm -rf "$tempDir"; fi \
    && if [ -n "/etc/apk/keys/abuild-key.rsa.pub" ]; then rm -f /etc/apk/keys/abuild-key.rsa.pub; fi \
    && if [ -n "/etc/apk/keys/nginx_signing.rsa.pub" ]; then rm -f /etc/apk/keys/nginx_signing.rsa.pub; fi \
# remove the last line with the packages repos in the repositories file
    && sed -i '$ d' /etc/apk/repositories \
# Bring in gettext so we can get `envsubst`, then throw
# the rest away. To do this, we need to install `gettext`
# then move `envsubst` out of the way so `gettext` can
# be deleted completely, then move `envsubst` back.
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
    && chown -R www-data:www-data /var/log/nginx \
    && chown -R www-data:www-data /workspace

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
