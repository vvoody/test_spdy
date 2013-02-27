class apache {
  package {'apache2':
    ensure => present,
  }

  service {'apache2':
    ensure => running,
  }

  $ownmodules = "/vagrant/puppet-modules/apache"
}
