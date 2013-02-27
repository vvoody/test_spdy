# create virtual ip
define create_vip($ip) {
  # virtual interface
  $vif = $title

  exec { "bind ip $ip to $vif":
    path => "/sbin",
    command => "ifconfig $vif $ip netmask 255.255.255.0 up"
  }
}

# 7 domains
create_vip { 'eth1:0': ip => '192.168.57.4' } # en.m.wikipedia.org
create_vip { 'eth1:1': ip => '192.168.57.5' } # upload.wikimedia.org
create_vip { 'eth1:2': ip => '192.168.57.6' } # bits.wikimedia.org
create_vip { 'eth1:3': ip => '192.168.57.7' } # bits-01.wikimedia.org
create_vip { 'eth1:4': ip => '192.168.57.8' } # bits-02.wikimedia.org
create_vip { 'eth1:5': ip => '192.168.57.9' } # upload-01.wikimedia.org
create_vip { 'eth1:6': ip => '192.168.57.10' } # upload-02.wikimedia.org
