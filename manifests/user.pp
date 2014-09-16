class hoodie::user {
  user { 'hoodie':
    ensure  => present,
    system  => true,
    home    => '/home/hoodie',
    comment => "Hoodie Administrator",
  }
}
