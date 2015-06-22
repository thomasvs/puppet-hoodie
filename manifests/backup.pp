# = Class: hoodie::backup
#
# This class backs up the couchdb database for each user on a daily basis.
#
# == Parameters
#
# [* ensure *]
#   What state to ensure for the module.
#   Default: present
#
# == Variables
#
# == Examples
#
# == Author
#
class hoodie::backup {
  file { [
      '/srv/backup', # FIXME: if others need this, extract to module
      '/srv/backup/couchdb-hoodie',
    ]:
    ensure => directory
  }

  # to work in cron, % needs to be escaped with \
  # otherwise, cron truncates the command after the + and never runs
  file { '/etc/cron.d/backup-couchdb-hoodie':
    ensure  => file,
    content => "# created by puppet
0 5 * * * root cd /srv/backup/couchdb-hoodie; for path in /var/lib/couchdb-hoodie/user/*.couch; do echo `date` copying user db \$path >> /var/log/backup-couchdb-hoodie.log; gzip < \$path > couchdb-hoodie-user-`basename -s .couch \$path`-`date +\%Y-\%m-\%d`.dump.gz; done
        "
  }

}
