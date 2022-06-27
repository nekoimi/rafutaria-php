#!/bin/sh
set -e

PHP_INI_DIR="/usr/local/etc/php"
PHP_CONF_DIR="/usr/local/etc/php-fpm.d"

# env
PHP_APPLICATION_ENV=${APPLICATION_ENV:-"dev"}
PHP_COMPOSER_INSTALL=${COMPOSER_INSTALL:-"false"}
PHP_COMPOSER_UPDATE=${COMPOSER_UPDATE:-"false"}
PHP_XDEBUG_ENABLE=${XDEBUG_ENABLE:-"false"}
PHP_PROC_MANAGER_MODE=${PHP_PM_MODE:-"dynamic"}
PHP_PROC_MAX_CHILDREN=${PHP_PM_MAX_CHILDREN:-"5"}
PHP_PROC_START_SERVERS=${PHP_PM_START_SERVERS:-"2"}
PHP_PROC_MIN_SPARE_SERVERS=${PHP_PM_MIN_SPARE_SERVERS:-"1"}
PHP_PROC_MAX_SPARE_SERVERS=${PHP_PM_MAX_SPARE_SERVERS:-"3"}
PHP_PROC_MAX_REQUESTS=${PHP_PM_MAX_REQUESTS:-"500"}

exec_config_php_ini() {
  ### php.ini
  # copy php.ini
  if [ -f $PHP_INI_DIR/php.ini-production ]; then
    if [ -f $PHP_INI_DIR/php.ini ]; then
      rm -f $PHP_INI_DIR/php.ini
    fi
    cp -f $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
    # config resource
    sed -i 's/max_execution_time = 60/max_execution_time = 60/g' $PHP_INI_DIR/php.ini
    sed -i 's/memory_limit = 128M/memory_limit = 128M/g' $PHP_INI_DIR/php.ini
    sed -i 's/post_max_size = 8M/post_max_size = 10M/g' $PHP_INI_DIR/php.ini
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' $PHP_INI_DIR/php.ini
    sed -i 's/max_file_uploads = 20/max_file_uploads = 1/g' $PHP_INI_DIR/php.ini
    # config opcache
    sed -i 's/;opcache.enable=1/opcache.enable=1/g' $PHP_INI_DIR/php.ini
    sed -i 's/;opcache.memory_consumption=128/opcache.memory_consumption=128/g' $PHP_INI_DIR/php.ini
    sed -i 's/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=8/g' $PHP_INI_DIR/php.ini
    sed -i 's/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g' $PHP_INI_DIR/php.ini
    sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=2/g' $PHP_INI_DIR/php.ini
    sed -i 's/;opcache.fast_shutdown=0/opcache.fast_shutdown=0/g' $PHP_INI_DIR/php.ini
    sed -i 's/;opcache.enable_file_override=0/opcache.enable_file_override=1/g' $PHP_INI_DIR/php.ini
    sed -i 's/;opcache.validate_timestamps=1/opcache.validate_timestamps=1/g' $PHP_INI_DIR/php.ini
    sed -i 's/;opcache.file_cache=/opcache.file_cache=\/tmp/g' $PHP_INI_DIR/php.ini
    sed -i 's/;opcache.huge_code_pages=1/opcache.huge_code_pages=1/g' $PHP_INI_DIR/php.ini
  fi
}

exec_config_php_fpm() {
  ### www.conf
  if [ -f $PHP_CONF_DIR/www.conf.default ]; then
    if [ -f $PHP_CONF_DIR/www.conf ]; then
      rm -f $PHP_CONF_DIR/www.conf
    fi
    cp -f $PHP_CONF_DIR/www.conf.default $PHP_CONF_DIR/www.conf

    # 进程管理模式
    sed -i "s/pm = dynamic/pm = $PHP_PROC_MANAGER_MODE/g" $PHP_CONF_DIR/www.conf
    # 静态方式下开启的php-fpm进程数量
    sed -i "s/pm.max_children = 5/pm.max_children = $PHP_PROC_MAX_CHILDREN/g" $PHP_CONF_DIR/www.conf
    # 动态方式下的起始php-fpm进程数量
    sed -i "s/pm.start_servers = 2/pm.start_servers = $PHP_PROC_START_SERVERS/g" $PHP_CONF_DIR/www.conf
    # 动态方式下的最小php-fpm进程数量
    sed -i "s/pm.min_spare_servers = 1/pm.min_spare_servers = $PHP_PROC_MIN_SPARE_SERVERS/g" $PHP_CONF_DIR/www.conf
    # 动态方式下的最大php-fpm进程数量
    sed -i "s/pm.max_spare_servers = 3/pm.max_spare_servers = $PHP_PROC_MAX_SPARE_SERVERS/g" $PHP_CONF_DIR/www.conf
    # 请求数累积到一定数量后，自动重启该进程
    sed -i "s/;pm.max_requests = 500/pm.max_requests = $PHP_PROC_MAX_REQUESTS/g" $PHP_CONF_DIR/www.conf
  fi
}

exec_config_xdebug() {
  ### xdebug
  DOCKER_PHP_EXT_XDEBUG="$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini"
  if [ $PHP_XDEBUG_ENABLE == "true" ]; then
    if [ -f $DOCKER_PHP_EXT_XDEBUG ]; then
      rm -f $DOCKER_PHP_EXT_XDEBUG
    fi

    docker-php-ext-enable xdebug

    # xdebug2 和 xdebug3 的配置不同
    # 配置参考: https://xdebug.org/docs/all_settings
    XDEBUG_VERSION=$(php --ri xdebug | grep Version | awk -F '=>' '{print $2}' | awk -F . '{print $1}' | sed s/[[:space:]]//g)
    echo "xdebug version: $XDEBUG_VERSION"

    if [ $XDEBUG_VERSION == "2" ]; then
      echo 'xdebug.remote_enable = On' >> $DOCKER_PHP_EXT_XDEBUG
      echo 'xdebug.remote_log = /tmp/xdebug.log' >> $DOCKER_PHP_EXT_XDEBUG
      echo 'xdebug.remote_autostart = false' >> $DOCKER_PHP_EXT_XDEBUG
    fi

    if [ $XDEBUG_VERSION == "3" ]; then
      echo 'xdebug.mode = debug' >> $DOCKER_PHP_EXT_XDEBUG
      echo 'xdebug.client_port = 9003' >> $DOCKER_PHP_EXT_XDEBUG
      echo 'xdebug.collect_return = On' >> $DOCKER_PHP_EXT_XDEBUG
      echo 'xdebug.log = /tmp/xdebug.log' >> $DOCKER_PHP_EXT_XDEBUG
    fi

    echo 'Xdebug enabled!'
  else
    if [ -f $DOCKER_PHP_EXT_XDEBUG ]; then
      rm -f $DOCKER_PHP_EXT_XDEBUG
    fi
    echo 'Xdebug disabled!'
  fi
}

exec_config_composer() {
  ### composer
  if [ -f $WORKSPACE/composer.lock ]; then

    if [ $PHP_COMPOSER_INSTALL == "true" ]; then
      if [ $PHP_APPLICATION_ENV == "production" ]; then
        composer install --no-ansi --no-interaction --no-progress --no-dev --working-dir=$WORKSPACE
      else
        composer install --no-ansi --no-interaction --no-progress --working-dir=$WORKSPACE
      fi
    fi

    if [ $PHP_COMPOSER_UPDATE == "true" ]; then
      composer update -vvv --no-ansi --no-interaction --no-progress --working-dir=$WORKSPACE
    fi

    composer dump-autoload --optimize

  else
    echo 'composer.lock does not exists!  Ignore.'
  fi
}

_main() {
  exec_config_php_ini
  exec_config_php_fpm
  exec_config_xdebug
  exec_config_composer
}

_main "$@"
