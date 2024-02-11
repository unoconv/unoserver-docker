#!/bin/bash
set -e -u

# Function to wait for unoserver to start
wait_for_unoserver() {
    echo "Waiting for unoserver to start ..."
    while [ -z "$(netstat -tln | grep 2002)" ]; do
        sleep 1
    done
    echo "unoserver started."
    echo "using: $(libreoffice --version)"
}

export PS1='\u@\h:\w\$ '

# default parameters for supervisord
export SUPERVISOR_INTERACTIVE_CONF='/supervisor/conf/interactive/supervisord.conf'
export SUPERVISOR_NON_INTERACTIVE_CONF='/supervisor/conf/non_interactive/supervisord.conf'
export UNIX_HTTP_SERVER_PASSWORD=${UNIX_HTTP_SERVER_PASSWORD:-$(cat /proc/sys/kernel/random/uuid)}

echo "using: $(libreoffice --version)"

# if tty then assume that container is interactive
if [ ! -t 0 ]; then
    echo "Running unoserver-docker in non-interactive."
    echo "For interactive mode use '-it', e.g. 'docker run -v /tmp:/data -it unoserver/unoserver-docker'."

    # run supervisord in foreground
    supervisord -c "$SUPERVISOR_NON_INTERACTIVE_CONF"
else
    echo "Running unoserver-docker in interactive mode."
    echo "For non-interactive mode omit '-it', e.g. 'docker run -p 2002-2003:2002-2003 unoserver/unoserver-docker'."


    # run supervisord as detached
    supervisord -c "$SUPERVISOR_INTERACTIVE_CONF"

    # wait until unoserver started and listens on port 2002.
    wait_for_unoserver
    
    # if commands have been passed to container run them and exit, else start bash
    if [[ $# -gt 0 ]]; then
        eval "$@"
    else
        /bin/bash
    fi
fi
