class hoodie (
  $admins = hiera('hoodie::admins', {})
) {
  include hoodie::user
  include hoodie::install

  couchdb { 'couchdb-hoodie':
    port     => 5986,
    ssl_port => 6986,
    admins   => $admins,
  }
}
