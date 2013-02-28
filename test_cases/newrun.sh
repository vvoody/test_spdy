#!/bin/bash

# Run a complete round test of 1 protocol under all network combinations,
# which comprise all RTT and DW_BW.
#
# SSL and non-ssl are two sperate rounds.
#
# use 'DEBUG=echo bash $0' to do a dry run.

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

LOG_FILE=run.log
RUN_TIMES=5
# 'vagrant' host should be existed in ~/.ssh/config
REMOTE=${REMOTE:-vagrant}
# PROTOCOL should be lowercase, otherwise puppet cannot find the class.
# but run.py doesn't have to.
PROTO=${PROTOCOL/-/_}
# DEBUG=echo bash $0
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

$DEBUG fab -H $REMOTE touch_dummy_apache_config_files 2>&1 | tee -a $LOG_FILE
$DEBUG setup_apache ${PROTO,,} $SSL 2>&1 | tee -a $LOG_FILE

#echo "Please input something to continue... "
#read user_input
#echo $user_input


for dw_bw in $DW_BW_VALUES; do

    DW_BW=$dw_bw
    UP_BW=$(echo "$DW_BW/2" | bc)
    ARGS_STR="-l $LOSS -d $DW_BW -u $UP_BW -r"

    for rtt in $RTT_VALUES; do
        echo "**********" $(date) "**********" >> $LOG_FILE
        (cat <<EOF
===========================================================================
  Starting test of protocol '$PROTOCOL' with SSL('$SSL') and  parameters:
      $ARGS_STR $rtt
  under '$NETWORK' network.
===========================================================================
EOF
) | tee -a $LOG_FILE

        $DEBUG setup_remote_network "${ARGS_STR}" $rtt 2>&1 | tee -a $LOG_FILE
        $DEBUG sleep 1
        $DEBUG fab -H $REMOTE get_net 2>&1 | tee -a $LOG_FILE
        $DEBUG echo "Have a try to remote server, curl..." | tee -a $LOG_FILE
        curl -s -m 5 "http://${URL}" 2&>1 >/dev/null
        #curl -s -m 5 "https://${URL}" 2&>1 >/dev/null
        $DEBUG sleep 1
        $DEBUG python -u run.py -p ${PROTOCOL,,} $SSL_OPT -n $NETWORK ${ARGS_STR} $rtt -t $RUN_TIMES -v 2>&1 | tee -a $LOG_FILE

    # first time will fail for unknown reason, have to try twice.
        $DEBUG fab -H $REMOTE reset_net 2>&1 | tee -a $LOG_FILE
        $DEBUG sleep 1
        (cat <<EOF
===========================================================================
  END of this round test.
===========================================================================



EOF
) | tee -a $LOG_FILE
    done
done

$DEBUG fab -H $REMOTE reset_net 2>&1 | tee -a $LOG_FILE
# END.
