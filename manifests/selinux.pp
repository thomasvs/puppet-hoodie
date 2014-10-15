# Either include this class as is, or make sure the same statement
# is loaded somewhere else
class hoodie::selinux {
  @::selinux::flag { 'httpd_enable_homedirs-1':
    flag  => 'httpd_enable_homedirs',
    value => '1'
  }
}
