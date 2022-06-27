#!/bin/sh
set -e

NGX_CONF_FILE="/etc/nginx/nginx.conf"
NGX_CONF_TPL_FILE="/etc/nginx/nginx.conf.tpl"
NGX_CONF_DIR="/etc/nginx/conf.d"

# env
NGX_WORKER_PROC=${NGX_WORKER_PROC:-"1"}

_main() {
  if [ -f /usr/sbin/nginx ]; then
      ### nginx.conf
      if [ -f $NGX_CONF_FILE ]; then
        rm -f $NGX_CONF_FILE
      fi

      if [ -f $NGX_CONF_TPL_FILE ]; then
        cp -f $NGX_CONF_TPL_FILE $NGX_CONF_FILE
      fi

      if [ -f $NGX_CONF_FILE ]; then
        sed -i "s/NGX_WORKER_PROC/$NGX_WORKER_PROC/g" $NGX_CONF_FILE
      fi

      # default.conf
      if [ -f $WORKSPACE/docker/nginx/default.conf ]; then
          if [ -f $NGX_CONF_DIR/default.conf ]; then
            rm -f $NGX_CONF_DIR/default.conf
          fi
          cp -f $WORKSPACE/docker/nginx/default.conf $NGX_CONF_DIR/default.conf
      fi
  fi
}

_main "$@"
