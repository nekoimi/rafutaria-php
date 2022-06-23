#!/bin/sh
set -e

exec_config_supervisor() {
  # 后台守护进程配置
  ### /etc/supervisor.d
if /usr/bin/find "$WORKSPACE/deploy/supervisor/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
	echo "$0: $WORKSPACE/deploy/supervisor is not empty, will attempt to perform configuration"

	echo "$0: Looking for supervisor configs in $WORKSPACE/deploy/supervisor"
	find "$WORKSPACE/deploy/supervisor/" -follow -type f -print | sort -V | while read -r f; do
		case "$f" in
			*.ini)
				if [ -f "$f" ]; then
					echo "$0: Applying $f";
          FILE_NAME=$(echo "$f" | awk -F '/' '{print $NF}' | sed s/[[:space:]]//g)
					cp -f $f /etc/supervisor.d/$FILE_NAME
				else
					echo "$0: Ignoring $f, not exists";
				fi
				;;
			*) echo "$0: Ignoring $f";;
		esac
	done

	echo "$0: Configuration complete!"
else
	echo "$0: No files found in $WORKSPACE/deploy/supervisor, skipping configuration"
fi
}

_main() {
  exec_config_supervisor

  if [ -f /etc/supervisord.conf ]; then
    sed -i 's/;pidfile=\/run\/supervisord.pid/pidfile=\/run\/supervisord.pid/g' /etc/supervisord.conf
    sed -i 's/;childlogdir=\/var\/log\/supervisor/childlogdir=\/var\/log\/supervisor/g' /etc/supervisord.conf
  fi
}

_main "$@"