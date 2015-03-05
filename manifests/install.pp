# = Class: hoodie::install
#
class hoodie::install {
  package { [
    'npm',
  ]:
    ensure => present
  }

  selinux::audit2allow { 'hoodie':
    source => "puppet:///modules/hoodie/messages.hoodie",
    before => Couchdb['couchdb-hoodie'],

  } 

  # this flag virtual resource needs to be included previously
  realize(Selboolean['httpd_enable_homedirs-1'])

  file { '/home/hoodie/bin':
    ensure => directory,
  }

  file { '/home/hoodie/bin/hoodie-daemon.sh':
    ensure => present,
    source => 'puppet:///modules/hoodie/hoodie-daemon.sh',
    mode   => '0755',
  }

  # on RHEL 5-6-7, sudoers defaults to requiretty, which stops hoodie-daemon.sh
  file { "/etc/sudoers.d/hoodie":
    ensure  => 'present',
    content => template('hoodie/sudoers.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
  }


}
