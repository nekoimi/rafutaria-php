#!/bin/sh
set -e

PHP_CRONTAB_ENABLE=${CRONTAB_ENABLE:-"false"}

exec_config_crontab() {
  ### crontab.conf
  if [ $PHP_CRONTAB_ENABLE == "true" ]; then
    if [ ! -f /etc/crontabs/root.bak ]; then
      cp -f /etc/crontabs/root /etc/crontabs/root.bak
    fi

    if [ -f $WORKSPACE/crontab.conf ]; then
      cp -f /etc/crontabs/root.bak /etc/crontabs/root

      echo '# application cron' >> /etc/crontabs/root
      cat $WORKSPACE/crontab.conf >> /etc/crontabs/root

      crond;

      echo 'Cron start!'
    else
      echo 'Cron file crontab.conf does not exists! Ignore.'
    fi
  fi
}

_main() {
  exec_config_crontab
}

_main "$@"