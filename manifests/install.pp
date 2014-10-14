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

  file { '/home/hoodie/bin':
    ensure => directory,
  }

  file { '/home/hoodie/bin/hoodie-daemon.sh':
    ensure => present,
    source => 'puppet:///modules/hoodie/hoodie-daemon.sh',
    mode   => '0755',
  }

}
