from fabric.api import run, sudo, env

# grant access to ~/.ssh/config
env.use_ssh_config = True
 
def host_type():
    run('uname -s')

def set_net(args_str, var):
    #sudo('bash /vagrant/setnet.sh -d 1024 -u 800 -l 0.03 -r 110')
    sudo( 'bash /vagrant/setnet.sh %s %s' % (args_str, var) )

def reset_net():
    sudo( 'bash /vagrant/setnet.sh -f' )

def get_net():
    sudo( 'ipfw pipe show' )

def touch_dummy_apache_config_files():
    """Don't know why below command fails, have to touch two dummy files
    to trigger Puppet to restart Apache.

    #sudo( 'service apache2 restart 2>/dev/null' )
    """

    sudo( 'touch /etc/apache2/mods-enabled/spdy.conf' )
    sudo( 'touch /etc/apache2/mods-enabled/spdy.load' )

def set_apache(proto, ssl_enabled='false'):
    sudo( '''puppet -e "class {'apache::testcase::%s': ssl_enabled => '%s'}" ''' % (proto, ssl_enabled) )
