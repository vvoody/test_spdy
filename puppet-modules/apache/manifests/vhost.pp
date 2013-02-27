# Definition: apache::vhost
#
# This class installs Apache Virtual Hosts
#
# Parameters:
# - The $port to configure the host on
# - The $docroot provides the DocumentationRoot variable
# - The $template option specifies whether to use the default template or override
# - The $priority of the site
# - The $serveraliases of the site
# - The $options for the given vhost
# - The $vhost_ip for <VirtualHost $vhost_ip:80>, defaulting to *
#
# Actions:
# - Install Apache Virtual Hosts
#
# Requires:
# - The apache class
#
# Sample Usage:
#  apache::vhost { 'site.name.fqdn':
#    vhost_ip => '192.168.57.4',      # virtual ip on your server, e.g. eth0:0
#  }
#
# You'll have a website at /var/www/site.name/fqdn/ on your server.
# And if you map site.name.fqdn to 192.168.57.4 on local, you can access
# http://site.name.fqdn/ directly.
# You may need configure a virtual ip on your server, like:
#    ifconfig eth0:0 192.168.57.4 netmask 255.255.255.0 up
#
# apache::vhost { 'secure.name.fqdn':
#    ssl_enabled => 'true',
#    port => 443,   # if you enable SSL, plz change port, otherwise it'll use 80
# }
#
# You'll have a website at /var/www/secure.name.fqdn/ on you server.
# And if you map secure.name.fqdn to server's ip on local, you can acces
# https://secure.name.fqdn/ directly.
# There are two helpful scripts helping generate a SSL certificate and
# import it to local, which means you self-sign that crt and trust it.
#
define apache::vhost(
  $servername    = '',
  $docroot       = '',
  $vhost_ip      = '*',
  $port          = 80,
  $ip            = '0.0.0.0',
  $ssl_enabled   = 'false',
  $template      = 'apache/vhost-default.conf.erb',
  $priority      = '25',
  $serveraliases = '',
  $options       = "Indexes FollowSymLinks MultiViews",
  ) {

    include apache
    
    # Below is a pre-2.6.5 idiom for having a parameter default to the title, 
    # but you could also just declare $servername = "$title" in the parameters
    # list and change srvname to servername in the template.

    if $servername == '' {
      $srvname = $title
    } else {
      $srvname = $servername
    }

    if $docroot == '' {
      $document_root = "/var/www/$srvname"
    } else {
      $document_root = $docroot
    }

    file { $document_root:
      ensure => directory,
      owner  => 'www-data',
      group  => 'www-data',
    }

    $vdir   = '/etc/apache2/sites-available'
    $logdir = '/var/log/apache2'
    $service_name = 'apache2'
    $cert_file = "/etc/ssl/${srvname}.crt"
    $cert_keyfile = "/etc/ssl/${srvname}.key"

    if $ssl_enabled == "true" {  # HTTPS
      file { $cert_file:
        ensure => link,
        target => "$apache::ownmodules/files/certs/${srvname}/${srvname}.crt",
        notify  => Service[$service_name],
      }

      file { $cert_keyfile:
        ensure => link,
        target => "$apache::ownmodules/files/certs/${srvname}/${srvname}.key",
        notify  => Service[$service_name],
      }
      $conf_name = "${priority}-${srvname}-ssl.conf"
    } else {
      $conf_name = "${priority}-${srvname}.conf"
    }

    $conf_file = "/etc/apache2/sites-available/${conf_name}"
    file { $conf_file:
      content => template($template),
      owner   => 'root',
      group   => 'root',
      mode    => '644',
      notify  => Service[$service_name],
    }

    # enable conf
    file { "/etc/apache2/sites-enabled/${conf_name}":
      ensure => link,
      target => $conf_file,
      notify  => Service[$service_name],
    }

  }
