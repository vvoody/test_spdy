# Localization of http://en.m.wikipedia.org/wiki/Lionel_Messi
#
# This mobile page has resource files distributed in three domains,
# they are mapped locally as:
#
#   eth1:0    192.168.57.4    en.m.wikipedia.org
#   eth1:1    192.168.57.5    upload.wikimedia.org
#   eth1:2    192.168.57.6    bits.wikimedia.org
#
# Please map them in your /etc/hosts file later.
#

apache::vhost { 'en.m.wikipedia.org':
  vhost_ip => '192.168.57.4',
}

apache::vhost { 'en.m.wikipedia.org':
  vhost_ip => '192.168.57.4',
  ssl_enabled => 'true',
  port => 443,
}

apache::vhost { 'upload.wikimedia.org':
  vhost_ip => '192.168.57.5',
}

apache::vhost { 'upload.wikimedia.org':
  vhost_ip => '192.168.57.5',
  ssl_enabled => 'true',
  port => 443,
}

apache::vhost { 'bits.wikimedia.org':
  vhost_ip => '192.168.57.6',
}

apache::vhost { 'bits.wikimedia.org':
  vhost_ip => '192.168.57.6',
  ssl_enabled => 'true',
  port => 443,
}
