class hoodie::user {
  user { 'hoodie':
    ensure     => present,
    system     => true,
    home       => '/home/hoodie',
    managehome => true,
    comment    => "Hoodie Administrator",
  }

  # apache needs to be able to 'execute' the directory
  file { '/home/hoodie':
    ensure  => directory,
    mode    => '0711',
    require => User['hoodie'],
  }
}
