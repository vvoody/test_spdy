# mod_ssl is always enabled.
#  mods-available/spdy.conf__________  (ssl enabled)
#                                    \
#                                     \
#                                      ---->  mods-enabled/spdy.conf
#                                     /
#  mods-available/spdy-no-ssl.conf___/ (ssl disabled)
#                       |
#                       V
#     SpdyDebugUseSpdyForNonSslConnections 2
class apache::testcase::spdy($ssl_enabled='true') {
  include apache

  file {'/etc/apache2/mods-enabled/spdy.load':
    ensure => link,
    target => '/etc/apache2/mods-available/spdy.load',
    notify => Service['apache2'],
  }

  if $ssl_enabled == "false" {
    file {'spdy-no-ssl':
      path   => '/etc/apache2/mods-enabled/spdy.conf',
      ensure => link,
      target => '/etc/apache2/mods-available/spdy-no-ssl.conf',
      notify => Service['apache2'],
    }
  } else {
    file {'spdy-ssl':
      path   => '/etc/apache2/mods-enabled/spdy.conf',
      ensure => link,
      target => '/etc/apache2/mods-available/spdy.conf',
      notify => Service['apache2'],
    }
  }
}
