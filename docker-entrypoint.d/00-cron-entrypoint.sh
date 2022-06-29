#!/bin/sh
set -e

PHP_CRONTAB_ENABLE=${CRONTAB_ENABLE:-"false"}

_main() {
  ### crontab.conf
  if [ $PHP_CRONTAB_ENABLE == "true" ]; then
    if [ ! -f /etc/crontabs/root.bak ]; then
      cp -f /etc/crontabs/root /etc/crontabs/root.bak
    fi

    cp -f /etc/crontabs/root.bak /etc/crontabs/root

    if [ ! -f $WORKSPACE/crontab.conf ]; then
      echo "$WORKSPACE/crontab.conf ignore"
    else
      echo '' >> /etc/crontabs/root
      echo "# cron from $WORKSPACE/crontab.conf" >> /etc/crontabs/root
      cat $WORKSPACE/crontab.conf >> /etc/crontabs/root
      echo "# end" >> /etc/crontabs/root
      echo '' >> /etc/crontabs/root
    fi

    if [ -d $WORKSPACE/docker/crontab ]; then
      if /usr/bin/find "$WORKSPACE/docker/crontab/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
        echo "$0: $WORKSPACE/docker/crontab/ is not empty, will attempt to perform configuration"

        echo "$0: Looking for crond configs in $WORKSPACE/docker/crontab"
        find "$WORKSPACE/docker/crontab/" -follow -type f -print | sort -V | while read -r f; do
          case "$f" in
            *.conf)
              if [ -f "$f" ]; then
                echo "$0: Applying $f";
                echo '' >> /etc/crontabs/root
                echo "# cron from $f" >> /etc/crontabs/root
                cat $f >> /etc/crontabs/root
                echo "# end" >> /etc/crontabs/root
                echo '' >> /etc/crontabs/root
              else
                echo "$0: Ignoring $f, not exists";
              fi
              ;;
            *) echo "$0: Ignoring $f";;
          esac
        done

        echo "$0: Configuration complete!"
      else
        echo "$0: No files found in $WORKSPACE/docker/crontab, skipping configuration"
      fi
    fi

    # Start crond.
    crond;
    echo 'Crond Start!'
  fi
}

_main "$@"