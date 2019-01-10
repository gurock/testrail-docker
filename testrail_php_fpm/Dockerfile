ARG ARG_PHP_VERSION=7.0
FROM php:${ARG_PHP_VERSION}-fpm

ARG ARG_PHP_VERSION=7.0
ARG ARG_IONCUBE_VERSION=10.2.4

LABEL vendor="TestRail" \
      maintainer="Christian Breitwieser" \
      email="cbreitwieser@ranorex.com" \
      type="TestRail php-fpm image including ionCube loader." \
      description="This is an image which runs php-fpm with ionCube for testrail."

RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends curl zip unzip wget mariadb-client && \
    apt-get install -y --no-install-recommends zlib1g-dev libcurl4-gnutls-dev libldap2-dev zlib1g-dev libxml2-dev && \
    apt-get clean && \
    docker-php-ext-install mbstring && \
    if [ "x$ARG_PHP_VERSION" = "5."* ] ; then docker-php-ext-install mysql; \
    else docker-php-ext-install mysqli; \
    fi && \
    docker-php-ext-install curl && \
    docker-php-ext-install zip && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu && \
    docker-php-ext-install ldap && \
    rm -rf /var/lib/apt/lists/*

COPY php.ini /usr/local/etc/php/conf.d/php.ini

RUN \
  wget  -O /tmp/ioncube.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64_${ARG_IONCUBE_VERSION}.tar.gz && \
  tar -xzf /tmp/ioncube.tar.gz -C /tmp && \
  mv /tmp/ioncube /opt/ioncube && \
  echo zend_extension=/opt/ioncube/ioncube_loader_lin_${ARG_PHP_VERSION}.so >> /usr/local/etc/php/php.ini && \
  rm -f /tmp/ioncube.tar.gz

COPY custom-entrypoint.sh /custom-entrypoint.sh
ENTRYPOINT ["/custom-entrypoint.sh"]
CMD ["php-fpm"]

EXPOSE 9000
