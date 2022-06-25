#!/bin/sh
set -e

PHP_CRONTAB_ENABLE=${CRONTAB_ENABLE:-"false"}

_main() {
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

      echo 'Cron Start!'
    else
      echo 'Cron Ignore!'
    fi
  fi
}

_main "$@"