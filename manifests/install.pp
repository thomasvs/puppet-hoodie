# = Class: hoodie::install
#
class hoodie::install {
  package { [
    'npm',
  ]:
    ensure => present
  }
  
}
