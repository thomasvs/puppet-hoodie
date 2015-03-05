# Either include this class as is, or make sure the same statement
# is loaded somewhere else
class hoodie::selinux {
  @selboolean { 'httpd_enable_homedirs-1':
    name       => 'httpd_enable_homedirs',
    persistent => true,
    value      => 'on',
  }
}
