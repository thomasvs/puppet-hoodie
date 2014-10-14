define hoodie::app (
  $gitrepo,
  $commit=undef
) {

  $directory = "/home/hoodie/${name}"

  $checkoutdir = 'checkout'
  $fullpath = "${directory}/${checkoutdir}"

  $user = 'hoodie'

  git::checkout { $name:
    directory   => $directory,
    checkoutdir => $checkoutdir,
    repository  => $gitrepo,
    user        => $user,
    commit      => $commit
  }

  exec { "hoodie-npm-install-${name}":
    command => 'npm install',
    user    => $user,
    path    => '/usr/bin',
    cwd     => $fullpath,
    require => [
      Git::Checkout[$name],
    ]
  }

  $admins = hiera('hoodie::admins')
  $admin_user = inline_template('<%= @admins.keys.first %>')
  $admin_password = $admins[$admin_user]

  exec { "hoodie-start-${name}":
    command => 'hoodie-daemon.sh start',
    path    => '/usr/bin:/home/hoodie/bin',
    cwd     => $fullpath,
    creates => "${fullpath}/run/hoodie.pid",
    environment => [
      'HOODIE_APP_HOME=/home/hoodie/mushin/checkout',
      "HOODIE_ADMIN_USER=${admin_user}",
      "HOODIE_ADMIN_PASS=${admin_password}",
      "HOODIE_PORT=5986",
#      "HOODIE_PORT=6986",
#      "HOODIE_PROTOCOL=https",
    ],
    require => [
      Exec["hoodie-npm-install-${name}"],
    ],
  }

}
