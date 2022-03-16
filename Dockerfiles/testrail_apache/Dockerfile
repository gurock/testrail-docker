ARG ARG_PHP_VERSION=7.2
FROM php:${ARG_PHP_VERSION}-apache

ARG ARG_PHP_VERSION=7.3
ARG ARG_IONCUBE_VERSION=10.3.2
ARG ARG_URL=https://secure.gurock.com/downloads/testrail/testrail-latest-ion71.zip

ENV TR_DEFAULT_TASK_EXECUTION=60
ENV TR_CONFIGPATH="/var/www/testrail/config/"
ENV TR_DEFAULT_LOG_DIR="/opt/testrail/logs/"
ENV TR_DEFAULT_AUDIT_DIR="/opt/testrail/audit/"
ENV TR_DEFAULT_REPORT_DIR="/opt/testrail/reports/"
ENV TR_DEFAULT_ATTACHMENT_DIR="/opt/testrail/attachments/"
ENV OPENSSL_CONF=/etc/ssl/

LABEL vendor="TestRail" \
      maintainer="Christian Breitwieser" \
      email="cbreitwieser@ranorex.com" \
      type="TestRail php-fpm apache image including ionCube loader." \
      description="This is an image which runs apache php-fpm with ionCube for testrail."

RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends curl zip unzip wget iputils-ping mariadb-client openssl && \
    apt-get install -y --no-install-recommends libzip-dev zlib1g-dev libcurl4-gnutls-dev libldap2-dev zlib1g-dev libxml2-dev libfontconfig1 libpng-dev libjpeg-dev && \
    apt-get install -y --only-upgrade apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN \
    docker-php-ext-install mbstring && \
    if [ "x$ARG_PHP_VERSION" = "5."* ] ; then docker-php-ext-install mysql; \
    else docker-php-ext-install mysqli; \
    fi && \
    docker-php-ext-install curl && \
    docker-php-ext-install zip && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu && \
    docker-php-ext-install ldap && \
    docker-php-ext-install pdo && \
    docker-php-ext-install gd && \
    docker-php-ext-install pdo_mysql

RUN \
  wget --no-check-certificate -O /tmp/testrail.zip ${ARG_URL} && \
  mkdir -p /var/www/testrail && \
  mkdir -p /opt/testrail/attachments /opt/testrail/reports /opt/testrail/logs /opt/testrail/audit && \
  unzip /tmp/testrail.zip -d /var/www/ && \
  rm /tmp/testrail.zip && \
  chown -R www-data:www-data /var/www/testrail && \
  chown -R www-data:www-data /opt/testrail

COPY php.ini /usr/local/etc/php/conf.d/php.ini

RUN \
  wget  -O /tmp/ioncube.tar.gz http://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64_${ARG_IONCUBE_VERSION}.tar.gz && \
  tar -xzf /tmp/ioncube.tar.gz -C /tmp && \
  mv /tmp/ioncube /opt/ioncube && \
  echo zend_extension=/opt/ioncube/ioncube_loader_lin_${ARG_PHP_VERSION}.so >> /usr/local/etc/php/php.ini && \
  rm -f /tmp/ioncube.tar.gz

RUN apt-get update
RUN apt-get -y install build-essential cmake git libkrb5-dev libtool libssl-dev libgmp-dev libpcre3-dev
RUN apt-get -y install gcc make autoconf libc-dev pkg-config
RUN apt-get -y install libmcrypt-dev
RUN pecl install --nodeps mcrypt-snapshot

RUN ( cd /tmp && \
      curl https://dist.libuv.org/dist/v1.35.0/libuv-v1.35.0.tar.gz -o libuv.tgz  && tar xzf libuv.tgz && \
      cd libuv-v1.35.0 && \
      sh autogen.sh && \
      ./configure && \
      make install \
    )
RUN rm -rf /tmp/libuv-v1.35.0 /tmp/libuv.tgz

RUN ( cd /tmp &&  \
      git clone https://github.com/datastax/cpp-driver && \
      cd cpp-driver && \
      mkdir build &&  \
      cd build && \
      cmake -DCMAKE_INSTALL_PREFIX=/usr .. && \
      make && \
      make install \
      )
RUN rm -rf /tmp/cpp-driver

RUN ( cd /tmp && \
      git clone https://github.com/datastax/php-driver && \
      cd php-driver && \
      git submodule update --init && \
      cd ext && \
      phpize && \
      ./configure && \
      make install \
    )
RUN rm -rf /tmp/php-driver
RUN mkdir -p /apache-conf
VOLUME /apache-conf

RUN mkdir -p /etc/apache2/ssl
VOLUME /etc/apache2/ssl

COPY apache_testrail.conf /apache-conf/000-default.conf
COPY ssl_apache_testrail.conf /apache-conf/ssl_apache_testrail.conf
COPY .htaccess /apache-conf/.htaccess

COPY custom-entrypoint.sh /custom-entrypoint.sh
ENTRYPOINT ["/custom-entrypoint.sh"]
CMD ["apache2-foreground"]

WORKDIR /var/www/testrail
EXPOSE 80
