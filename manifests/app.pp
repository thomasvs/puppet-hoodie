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
    # FIXME: if you change the hoodie-server dep, npm install without
    #        args doesn't necessarily update that
    command => 'npm install && npm install hoodie-server',
    user    => $user,
    path    => '/usr/bin',
    cwd     => $full_path,
    refreshonly => true,
    require => [
      Git::Checkout[$name],
    ]
  }

  exec { "hoodie-bower-install-${name}":
    # See https://github.com/bower/bower/issues/1102
    # for the option to skip the question to report statistics
    command => "bower install --config.interactive=false",
    user    => $user,
    path    => "/usr/bin:${full_path}/node_modules/.bin",
    cwd     => $full_path,
    refreshonly => true,
    require => [
      Git::Checkout[$name],
      Exec["hoodie-npm-install-${name}"],
    ]
  }


  exec { "hoodie-grunt-build-${name}":
    command     => 'grunt build',
    user        => $user,
    path        => "/usr/bin:${full_path}/node_modules/.bin",
    cwd         => $full_path,
    refreshonly => true,
    require     => [
      Git::Checkout[$name],
      Exec["hoodie-npm-install-${name}"],
      Exec["hoodie-bower-install-${name}"],
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
  selinux::filecontext { "${full_path}/www":
    seltype => 'httpd_sys_content_t',
    recurse => true
  }

  # deploy apache container
  apache_httpd::file { "container-hoodie-${name}.inc":
    ensure => file,
    content => template('hoodie/apache/container-hoodie.inc.erb'),
  }

  $httpd_version = $apache_httpd::params::httpd_version

  include apache_httpd::params

  # run commands on updated checkouts on second run
  file {"${directory}/commit":
    notify => [
      Exec["hoodie-npm-install-${name}"],
      Exec["hoodie-bower-install-${name}"],
      Exec["hoodie-grunt-build-${name}"],
    ],
    # audit makes puppet track the md5sum and hence it can
    # act on changes over runs
    audit => content,
  }

}
