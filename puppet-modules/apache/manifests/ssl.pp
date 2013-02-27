# CN: ubuntu1204.vagrant

class apache::ssl {
  include apache

  # package {'mod_ssl':
  #   ensure => present,
  # }

  exec {'enable-mod-ssl':
    command => '/usr/sbin/a2enmod ssl',
    notify => Service['apache2'],
  }

  exec {'enable-site-ssl':
    command => '/usr/sbin/a2ensite self-signed-ssl',
    require => File['self-signed-ssl'],
    notify => Service['apache2'],
  }

  file {'self-signed-ssl':
    path => '/etc/apache2/sites-available/self-signed-ssl',
    source => 'puppet:///modules/apache/self-signed-ssl',
    require => [ File['self-signed-ssl.crt'], File['self-signed-ssl.key'] ],
    notify => Service['apache2'],
  }

  file {'self-signed-ssl.crt':
    path => "/etc/ssl/self-signed-ssl.crt",
    ensure => file,
    source => 'puppet:///modules/apache/self-signed-ssl.crt',
  }

  file {'self-signed-ssl.key':
    path => "/etc/ssl/self-signed-ssl.key",
    ensure => file,
    source => 'puppet:///modules/apache/self-signed-ssl.key',
  }
}
