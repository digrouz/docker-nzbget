#!/usr/bin/env bash

. /etc/profile
. /usr/local/bin/docker-entrypoint-functions.sh

MYUSER="${APPUSER}"
MYUID="${APPUID}"
MYGID="${APPGID}"

AutoUpgrade

if [ "$1" == 'nzbget' ]; then
  if [ -f /downloads/nzbget.lock ]; then
    DockLog "Cleaning up lefover lock file"
    rm /downloads/nzbget.lock
  fi
  if [ ! -f /config/nzbget.conf ]; then
    DockLog "No config file detected in /config, copying template."
    cp /opt/nzbget/nzbget.conf /config/nzbget.conf
  fi
  if [ ! -h /opt/nzbget/downloads/nzbget.log ]; then
    DockLog "Redirecting logs to container output"
    ln -snf /proc/self/fd/2 /opt/nzbget/downloads/nzbget.log
  fi
  DockLog "Fixing permissions on /config /downloads /incomplete-downloads"
  chown -R ${MYUSER}:${MYUSER} /config /downloads /incomplete-downloads
  RunDropletEntrypoint
  DockLog "Starting app: ${1}"
  exec su-exec ${MYUSER} /opt/nzbget/nzbget \
	  -s \
	  -c /config/nzbget.conf \
	  -o OutputMode=log \
	  -o TempDir=/incomplete-downloads/tmp \
	  -o QueueDir=/incomplete-downloads/queue \
	  -o InterDir=/incomplete-downloads/intermediate \
	  -o NzbDir=/config/nzb \
	  -o ScriptDir=/config/scripts \
	  -o DestDir=/downloads
else
  DockLog "Starting app: ${@}"
  exec "$@"
fi

