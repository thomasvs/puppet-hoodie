define hoodie::app (
  $gitrepo,
  $commit=undef
) {

  $directory = "/home/hoodie/${name}"

  $checkoutdir = 'checkout'
  $full_path = "${directory}/${checkoutdir}"

  $user = 'hoodie'
  $url_prefix = ''
  $hoodie_port = '6002'

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
    cwd     => $full_path,
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
    cwd     => $full_path,
    creates => "${full_path}/run/hoodie.pid",
    environment => [
      "HOODIE_APP_HOME=${full_path}",
      "HOODIE_ADMIN_USER=${admin_user}",
      "HOODIE_ADMIN_PASS=${admin_password}",
      "HOODIE_PORT=5986",
#      "HOODIE_PORT=6986",
#      "HOODIE_PROTOCOL=https",
    ],
    require => [
      Exec["hoodie-npm-install-${name}"],
      File["/home/hoodie/bin/hoodie-daemon.sh"],
    ],
  }

  # make sure apache is allowed access to files
  selinux::filecontext { "${full_path}/app":
    seltype => 'httpd_sys_content_t',
    recurse => true
  }

  # deploy apache container
  apache_httpd::file { "container-hoodie-${name}.inc":
    ensure => file,
    content => template('hoodie/apache/container-hoodie.inc.erb'),
  }
}
