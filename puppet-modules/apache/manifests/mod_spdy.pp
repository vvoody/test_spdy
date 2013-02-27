class apache::mod_spdy {
  include apache

  package {'mod-spdy-beta':
    ensure => installed,
    provider => dpkg,
    source => "$apache::ownmodules/files/mod-spdy-beta_current_i386.deb",
    notify => Service['apache2'],
  }
}
