#!/bin/sh
set -e

# ssl option not required (assume the role of https by nginx)
sed -i \
    -e "s/\['host'\] = 'localhost'/\['host'\] = getenv(\"PHPIPAM_MYSQL_HOST\")/" \
    -e "s/\['user'\] = 'phpipam'/\['user'\] = getenv(\"PHPIPAM_MYSQL_USER\")/" \
    -e "s/\['pass'\] = 'phpipamadmin'/\['pass'\] = getenv(\"PHPIPAM_MYSQL_PASSWORD\")/" \
    -e "s/\['name'\] = 'phpipam'/\['name'\] = getenv(\"PHPIPAM_MYSQL_DB\")/" \
    -e "s/\['port'\] = 3306/\['port'\] = getenv(\"PHPIPAM_MYSQL_PORT\")/" \
    -e "s/\['ping_check_send_mail'\] *= true/\['ping_check_send_mail'\] = getenv(\"PHPIPAM_PING_CHECK_SEND_MAIL\")/" \
    -e "s/\['ping_check_method'\] *= false/\['ping_check_method'\] = getenv(\"PHPIPAM_PING_CHECK_METHOD\")/" \
    -e "s/\['discovery_check_send_mail'\] *= true/\['discovery_check_send_mail'\] = getenv(\"PHPIPAM_DISCOVERY_CHECK_SEND_MAIL\")/" \
    -e "s/\['discovery_check_method'\] *= false/\['discovery_check_method'\] = getenv(\"PHPIPAM_DISCOVERY_CHECK_METHOD\")/" \
    -e "s/\['removed_addresses_send_mail'\] *= true/\['removed_addresses_send_mail'\] = getenv(\"PHPIPAM_REMOVED_ADDR_CHECK_SEND_MAIL\")/" \
    -e "s/\['removed_addresses_timelimit'\] *= 86400 \* 7/\['removed_addresses_timelimit'\] = getenv(\"PHPIPAM_REMOVED_ADDR_CHECK_METHOD\")/" \
    -e "s/\['resolve_emptyonly'\] *= true/\['resolve_emptyonly'\] = getenv(\"PHPIPAM_RESOLVE_EMPTYONLY\")/" \
    -e "s/\['resolve_verbose'\] *= true/\['resolve_verbose'\] = getenv(\"PHPIPAM_RESOLVE_VERBOSE\")/" \
    -e "s/\$proxy_enabled *= false/\$proxy_enabled = getenv(\"PHPIPAM_PROXY_ENABLED\")/" \
    -e "s/\$proxy_server *= 'myproxy.something.com'/\$proxy_server = getenv(\"PHPIPAM_PROXY_SERVER\")/" \
    -e "s/\$proxy_port *= '8080'/\$proxy_port = getenv(\"PHPIPAM_PROXY_PORT\")/" \
    -e "s/\$proxy_user *= 'USERNAME'/\$proxy_user = getenv(\"PHPIPAM_PROXY_USERNAME\")/" \
    -e "s/\$proxy_pass *= 'PASSWORD'/\$proxy_pass = getenv(\"PHPIPAM_PROXY_PASSWORD\")/" \
    -e "s/\$proxy_use_auth *= false/\$proxy_use_auth = getenv(\"PHPIPAM_PROXY_USE_AUTH\")/" \
    /var/www/html/config.php

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
  set -- php-fpm "$@"
fi

exec "$@"
