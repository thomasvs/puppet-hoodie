a puppet module to manage hoodie

See https://github.com/hoodiehq/my-first-hoodie/blob/master/deployment.md

== Debugging ==

 * to test startup of couchdb the way systemctl would start it up:
    `/usr/libexec/couchdb +Bd -noinput -sasl errlog_type error +K true +A 4 -couch_ini /etc/couchdb/default.ini /etc/couchdb/default.d/ /etc/couchdb-hoodie/local.d/ /etc/couchdb-hoodie/local.ini -s couch -pidfile /var/run/couchdb/couchdb-hoodie.pid`
