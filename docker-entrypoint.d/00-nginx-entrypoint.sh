#!/bin/sh
set -e

NGX_CONF_FILE="/etc/nginx/nginx.conf"
NGX_CONF_TPL_FILE="/etc/nginx/nginx.conf.tpl"
NGX_CONF_DIR="/etc/nginx/conf.d"

# env
NGX_WORKER_PROC=${NGX_WORKER_PROCESSES:-"1"}

_main() {
  ### nginx.conf
  if [ -f $NGX_CONF_FILE ]; then
      rm -f $NGX_CONF_FILE
  fi

  cp -f $NGX_CONF_TPL_FILE $NGX_CONF_FILE

  sed -i "s/NGX_WORKER_PROC/$NGX_WORKER_PROC/g" $NGX_CONF_FILE

  # default.conf
  if [ -f $WORKSPACE/deploy/nginx/default.conf ]; then
      if [ -f $NGX_CONF_DIR/default.conf ]; then
        rm -f $NGX_CONF_DIR/default.conf
      fi
      cp -f $WORKSPACE/deploy/nginx/default.conf $NGX_CONF_DIR/default.conf
  fi

}

_main "$@"
