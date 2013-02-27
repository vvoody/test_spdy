# make sure essential packages and apache installed.

exec { 'update apt':
  command => "apt-get update",
  path => "/usr/bin:/bin",
  unless => "echo $(find . -type f -mtime -1 | wc -l)",  # not updated in last 24 hours
  logoutput => true,
}

package { 'ntp':
  ensure => absent,
}

$required_packages = ['make', 'vim', "linux-headers-$kernelrelease",
                      'git', 'subversion', 'curl']

package { $required_packages:
  ensure => installed,
}

file {'/etc/puppet/puppet.conf':
  ensure => file,
  content => "[main]\n  modulepath = /etc/puppet/modules:/usr/share/puppet/modules:/vagrant/puppet-modules\n",
}

include apache
