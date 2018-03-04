FROM php:5.6-fpm-alpine
MAINTAINER Tsubasa Nagano <networkmgmt [at] icloud.com>

# Install required apk packages
RUN set -ex && \
		apk update && \
    apk add --no-cache --virtual .build-deps \
        build-base \
        linux-headers \
        musl-dev \
        coreutils \
        php5-dev \
        libjpeg-turbo-dev \
        gettext-dev \
        gmp-dev \
        libmcrypt-dev \
        freetype-dev \
        openldap-dev \
    && \
    apk add --no-cache --virtual .docker-phpize-deps $PHPIZE_DEPS && \
    apk add --no-cache --virtual .run-deps \
        php5-pear \
        php5-curl \
        php5-gmp \
        php5-json \
        libpng \
        libjpeg-turbo \
        gettext \
        libmcrypt \
        freetype \
        openldap \
				fping \
    && \
    docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
    docker-php-ext-install -j$(nproc) mysqli && \
    docker-php-ext-install -j$(nproc) pdo_mysql && \
    docker-php-ext-install -j$(nproc) gettext && \
    docker-php-ext-install -j$(nproc) gmp && \
    docker-php-ext-install mcrypt && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd && \
    docker-php-ext-install -j$(nproc) sockets && \
    docker-php-ext-install -j$(nproc) pcntl && \
    docker-php-ext-install ldap && \
    apk del .docker-phpize-deps .build-deps && \
    rm -rf /var/cache/apk/* /var/tmp/* /tmp/*

ARG PHPIPAM_SOURCE=https://github.com/phpipam/phpipam.git
ARG PHPIPAM_VERSION=1.3.1

# copy phpipam sources to web dir
RUN apk update && \
    apk add --no-cache --virtual .build-deps \
        git \
        ca-certificates \
    && \
    git clone --depth=1 $PHPIPAM_SOURCE /var/www/html && \
    cd /var/www/html && \
    git checkout -b $PHPIPAM_VERSION && \
    cp ./config.dist.php ./config.php && \
    apk del .build-deps && \
    rm -rf /var/www/html/.git/ && \
    rm -rf /var/cache/apk/* /var/tmp/* /tmp/*

# copy nginx.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# override entrypoint shell, it rewrites system environment variables into config.php
COPY docker-entrypoint.sh /usr/local/bin/docker-php-entrypoint
RUN chmod +x /usr/local/bin/docker-php-entrypoint
ENTRYPOINT ["docker-php-entrypoint"]

# Set default paramaters of init phpIPAM
ENV PHPIPAM_MYSQL_HOST="database" \
		PHPIPAM_MYSQL_USER="root" \
		PHPIPAM_MYSQL_PASSWORD="phpipamadmin" \
		PHPIPAM_MYSQL_DB="phpipam" \
		PHPIPAM_PING_CHECK_SEND_MAIL="false" \
		PHPIPAM_PING_CHECK_METHOD="false" \
		PHPIPAM_DISCOVERY_CHECK_SEND_MAIL="false" \
		PHPIPAM_DISCOVERY_CHECK_METHOD="false" \
		PHPIPAM_REMOVED_ADDR_CHECK_SEND_MAIL="false" \
		PHPIPAM_REMOVED_ADDR_CHECK_METHOD="false" \
		PHPIPAM_RESOLVE_EMPTYONLY="true" \
		PHPIPAM_RESOLVE_VERBOSE="true" \
		PHPIPAM_PROXY_ENABLED="false" \
		PHPIPAM_PROXY_SERVER="proxy.local" \
		PHPIPAM_PROXY_PORT="8080" \
		PHPIPAM_PROXY_USERNAME="user" \
		PHPIPAM_PROXY_PASSWORD="passwd" \
		PHPIPAM_PROXY_USE_AUTH="false"

EXPOSE 9000
CMD ["php-fpm"]
