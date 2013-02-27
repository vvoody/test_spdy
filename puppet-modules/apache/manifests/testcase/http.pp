# mod_ssl is always enabled.
# HTTP & HTTP-PIPELINING only need to disable mod_spdy.
class apache::testcase::http($ssl_enabled='false') {
  include apache

  file {'/etc/apache2/mods-enabled/spdy.conf':
    ensure => absent,
    notify => Service['apache2'],
  }

  file {'/etc/apache2/mods-enabled/spdy.load':
    ensure => absent,
    notify => Service['apache2'],
  }
}
