#!/bin/sh
set -e

exec_config_supervisor() {
  # 后台守护进程配置
  ### /etc/supervisor.d
if /usr/bin/find "$WORKSPACE/docker/supervisor/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
	echo "$0: $WORKSPACE/docker/supervisor is not empty, will attempt to perform configuration"

	echo "$0: Looking for supervisor configs in $WORKSPACE/docker/supervisor"
	find "$WORKSPACE/docker/supervisor/" -follow -type f -print | sort -V | while read -r f; do
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
	echo "$0: No files found in $WORKSPACE/docker/supervisor, skipping configuration"
fi
}

_main() {
  exec_config_supervisor

#logfile=/var/log/supervisord.log ; (main log file;default $CWD/supervisord.log)
#  ;logfile_maxbytes=50MB       ; (max main logfile bytes b4 rotation;default 50MB)
#  ;logfile_backups=10          ; (num of main logfile rotation backups;default 10)
#  loglevel=info                ; (log level;default info; others: debug,warn,trace)
#pidfile=/run/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
#  ;nodaemon=false              ; (start in foreground if true;default false)
#  ;minfds=1024                 ; (min. avail startup file descriptors;default 1024)
#  ;minprocs=200                ; (min. avail process descriptors;default 200)
#  ;umask=022                   ; (process file creation umask;default 022)
#user=chrism                 ; (default is current user, required if root)
#  ;identifier=supervisor       ; (supervisord identifier, default is 'supervisor')
#  ;directory=/tmp              ; (default is not to cd during start)
#  ;nocleanup=true              ; (don't clean up tempfiles at start;default false)
#  ;childlogdir=/var/log/supervisor ; ('AUTO' child log dir, default $TEMP)
#  ;environment=KEY=value       ; (key value pairs to add to environment)
#  ;strip_ansi=false            ; (strip ansi escape codes in logs; def. false)


  if [ -f /etc/supervisord.conf ]; then
    sed -i 's#;user=chrism#user=root#g' /etc/supervisord.conf
    sed -i 's#;pidfile=/run/supervisord.pid#pidfile=/run/supervisord.pid#g' /etc/supervisord.conf
    sed -i 's#;childlogdir=/var/log/supervisor#childlogdir=/var/log/supervisor#g' /etc/supervisord.conf
  fi
}

_main "$@"