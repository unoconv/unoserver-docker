#!/bin/bash
set -e -u

# default parameters for supervisord
SUPERVISOR_PARAMS='-c /etc/supervisord.conf'

export PS1='\u@\h:\w\$ '

# if tty then assume that container is interactive
if [ ! -t 0 ]; then
  echo "Running image in detached mode is probably not meaningful."
  echo "Use interactive mode (-it), e.g. 'docker run -v /tmp:/data -it unoserver/unoserver-docker'."
  exit 1
fi

export UNIX_HTTP_SERVER_PASSWORD=${UNIX_HTTP_SERVER_PASSWORD:-`cat /proc/sys/kernel/random/uuid`}

# run supervisord detached...
supervisord $SUPERVISOR_PARAMS

# wait until unoserver started and listens on port 2002.
echo "Waiting for unoserver to start ..."
while [ -z "`netstat -tln | grep 2002`" ]; do
  # echo "Waiting for unoserver to start ..."
  sleep 1
done
echo "unoserver started."
libreoffice --version

# if commands have been passed to container run them and exit, else start bash
if [[ $@ ]]; then
  eval $@
else
  /bin/bash
fi