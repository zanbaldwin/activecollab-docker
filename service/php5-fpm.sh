#!/bin/sh
exec /usr/sbin/php5-fpm -R --nodaemonize --fpm-config /etc/php5/fpm/php-fpm.conf >> /var/log/php5-fpm.log 2>&1
