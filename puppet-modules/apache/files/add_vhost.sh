#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 FQDN IP"
fi


sn=$1
vip=$2

puppet apply <<EOF
apache::vhost { 'http':
  servername => "$sn",
  vhost_ip => "$vip",      # virtual ip on your server, e.g. eth0:0
}
EOF


puppet apply <<EOF
apache::vhost { 'https':
   servername => "$sn",
   ssl_enabled => 'true',
   vhost_ip => "$vip",
   port => 443,   # if you enable SSL, plz change port, otherwise it'll use 80
}
EOF
