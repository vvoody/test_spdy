#!/bin/bash

# Run a complete round test of 1 protocol under 1 network.
# SSL and non-ssl are two sperate round.

# $1 is the test case config file.
if [ $# -ne 1 ]; then
    echo "Usage: $0 test_case.conf"
    exit 1
fi

if [ -r $1 ]; then
    source $1
else
    echo "File '$1' does not exist."
    exit 1
fi

RUN_TIMES=5
# 'vagrant' host should be existed in ~/.ssh/config
REMOTE=${REMOTE:-vagrant}
# PROTOCOL should be lowercase, otherwise puppet cannot find the class.
# but run.py doesn't have to.
PROTO=${PROTOCOL/-/_}
# DEBUG=true bash $0
DEBUG=${DEBUG:- }
#
URL='en.m.wikipedia.org/'

if [ $SSL == "true" ]; then
    SSL_OPT="-s"
elif [ $SSL == "false" ]; then
    SSL_OPT=" "
else
    echo "'SSL' of case file was set incorrectly, which is '$SSL'."
    exit 1
fi

function setup_apache() {
    fab -H $REMOTE set_apache:proto=$1,ssl_enabled=$2
}


function setup_remote_network() {
    fab -H $REMOTE set_net:args_str="$1",var=$2
}

$DEBUG fab -H $REMOTE touch_dummy_apache_config_files
$DEBUG setup_apache ${PROTO,,} $SSL

#echo "Please input something to continue... "
#read user_input
#echo $user_input


for var in $VALUES; do
    cat <<EOF
===========================================================================
  Starting test of protocol '$PROTOCOL' with SSL('$SSL') and  parameters:
      $ARGS_STR $var
  under '$NETWORK' network.
===========================================================================
EOF
    $DEBUG setup_remote_network "${ARGS_STR}" $var
    $DEBUG sleep 1
    $DEBUG fab -H $REMOTE get_net
    echo "Have a try to remote server, curl..."
    curl -s -m 5 "http://${URL}" 2&>1 >/dev/null
    curl -s -m 5 "https://${URL}" 2&>1 >/dev/null
    $DEBUG sleep 2
    $DEBUG python run.py -p ${PROTOCOL,,} $SSL_OPT -n $NETWORK ${ARGS_STR} $var -t $RUN_TIMES -v

    # first time will fail for unknown reason, have to try twice.
    $DEBUG fab -H $REMOTE reset_net
    $DEBUG sleep 1
    $DEBUG fab -H $REMOTE reset_net
    $DEBUG sleep 1
    cat <<EOF
===========================================================================
  END of this round test.
===========================================================================



EOF
done

$DEBUG fab -H $REMOTE reset_net
# END.
