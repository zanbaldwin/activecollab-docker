# Use "phusion/baseimage" as base image. To make your builds reproducible, make sure you lock down to a specific
# version, not to "latest"! To see a list of version numbers, visit:
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
FROM        phusion/baseimage:0.9.17
MAINTAINER  Zander Baldwin <hello@zanderbaldwin.com>
VOLUME      /var/www
WORKDIR     /var/www
EXPOSE      80
# Don't forget to use the custom init system provided by phusion/baseimage.
CMD         ["/sbin/my_init"]

# Upgrade the Operating System.
RUN apt-get update \
 && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

# Install Nginx
RUN apt-get install -y nginx

# Setup the Nginx daemon.
RUN mkdir -p /etc/service/nginx
ADD service/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

# Add Nginx Configuration
ADD config/nginx.conf /etc/nginx/nginx.conf
ADD config/default-site /etc/nginx/sites-available/default

# Install PHP
RUN apt-get install -y \
    php5-cli \
    php5-curl \
    php5-fpm \
    php5-gd \
    php5-imap \
    php5-json \
    php5-mysqlnd

# Setup the PHP-FPM daemon.
RUN mkdir -p /etc/service/php5-fpm
ADD service/php5-fpm.sh /etc/service/php5-fpm/run
RUN chmod +x /etc/service/php5-fpm/run

# Add PHP Configuration
ADD config/pool-www.conf /etc/php5/fpm/pool.d/www.conf
ADD config/php.ini /etc/php5/fpm/php.ini
ADD config/php.ini /etc/php5/cli/php.ini
RUN ln -s /etc/php5/mods-available/imap.ini /etc/php5/cli/conf.d/20-imap.ini \
 && ln -s /etc/php5/mods-available/imap.ini /etc/php5/fpm/conf.d/20-imap.ini

# Install the CRON tab.
ADD config/crontab /etc/crontab

# Clean up APT when done.
RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
