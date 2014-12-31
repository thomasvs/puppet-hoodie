class hoodie (
  $admins = hiera('hoodie::admins', {})
) {
  include hoodie::user
  include hoodie::install

  couchdb { 'couchdb-hoodie':
    port          => 5986,
    ssl_port      => 6986,
    ssl_key_file  => '/etc/couchdb-hoodie/localhost.localdomain.key',
    ssl_cert_file => '/etc/couchdb-hoodie/localhost.localdomain.crt',
    admins        => $admins,
  }

  file { '/etc/couchdb-hoodie/localhost.localdomain.crt':
    ensure => file,
    source => 'puppet:///modules/hoodie/localhost.localdomain.crt',
    owner  => 'couchdb',
    group  => 'couchdb',
    mode   => '0400',
  }

  file { '/etc/couchdb-hoodie/localhost.localdomain.key':
    ensure => file,
    source => 'puppet:///modules/hoodie/localhost.localdomain.key',
    owner  => 'couchdb',
    group  => 'couchdb',
    mode   => '0400',
  }

}
