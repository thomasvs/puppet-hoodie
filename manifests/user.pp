class hoodie::user {
  user { 'hoodie':
    ensure     => present,
    system     => true,
    home       => '/home/hoodie',
    managehome => true,
    comment    => "Hoodie Administrator",
  }
}
