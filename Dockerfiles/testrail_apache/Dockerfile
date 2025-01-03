ARG ARG_PHP_VERSION=8.1
FROM php:${ARG_PHP_VERSION}-apache-bullseye

ARG ARG_PHP_VERSION=8.1
ARG ARG_IONCUBE_VERSION=12.0.5
ARG ARG_URL=https://secure.testrail.com/downloads/testrail/testrail-8.0.4.7036-ion81.zip

ENV TR_DEFAULT_TASK_EXECUTION=60
ENV TR_CONFIGPATH="/var/www/testrail/config/"
ENV TR_DEFAULT_LOG_DIR="/opt/testrail/logs/"
ENV TR_DEFAULT_AUDIT_DIR="/opt/testrail/audit/"
ENV TR_DEFAULT_REPORT_DIR="/opt/testrail/reports/"
ENV TR_DEFAULT_ATTACHMENT_DIR="/opt/testrail/attachments/"
ENV OPENSSL_CONF="/etc/ssl/"
ENV LDAP_CONF_DIR="/etc/ldap/"
ENV LDAP_CONF_FILE="$LDAP_CONF_DIR/ldap.conf"
ENV TR_CHROME_PATH="/usr/bin/chrome-headless-shell-linux64/chrome-headless-shell"

LABEL vendor="TestRail" \
      maintainer="Christian Breitwieser" \
      email="cbreitwieser@ranorex.com" \
      type="TestRail php-fpm apache image including ionCube loader." \
      description="This is an image which runs apache php-fpm with ionCube for testrail."

RUN \
    DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get upgrade -yqq && \
    apt-get install -y --no-install-recommends curl zip unzip wget iputils-ping mariadb-client openssl && \
    apt-get install -y --no-install-recommends libzip-dev zlib1g-dev libcurl4-gnutls-dev libldap2-dev zlib1g-dev libxml2-dev libfontconfig1 libpng-dev libjpeg-dev && \
    apt-get install -y --only-upgrade apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN \
    if [ "x$ARG_PHP_VERSION" = "5."* ] ; then docker-php-ext-install mysql; \
    else docker-php-ext-install mysqli; \
    fi && \
    docker-php-ext-install curl && \
    docker-php-ext-install zip && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu && \
    docker-php-ext-install ldap && \
    docker-php-ext-install pdo && \
    docker-php-ext-configure gd --enable-gd --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd && \
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
      git checkout tags/2.16.2 && \
      mkdir build &&  \
      cd build && \
      cmake -DCASS_BUILD_STATIC=ON -DCASS_BUILD_SHARED=ON -DCMAKE_INSTALL_PREFIX=/usr .. && \
      make -j4 && \
      make install \
      )
RUN rm -rf /tmp/cpp-driver

RUN ( cd /tmp && \
      git clone https://github.com/qkdreyer/cassandra-php-driver.git && \
      cd cassandra-php-driver && \
      git submodule update --init && \
      cd ext && \
      phpize && \
      ./configure && \
      make install \
    )

RUN ( cd /tmp && \
      apt-get update && \
      apt install -y libnss3 libatk1.0-0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libxkbcommon0 libasound2 libatk-bridge2.0-0 libxfixes3 && \
      LATEST_VERSION=$(wget -qO- https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE) && \
      wget https://storage.googleapis.com/chrome-for-testing-public/${LATEST_VERSION}/linux64/chrome-headless-shell-linux64.zip && \
      unzip "chrome-headless-shell-linux64.zip" && \
      mv chrome-headless-shell-linux64 /usr/bin && \
      chown www-data:www-data /usr/bin/chrome-headless-shell-linux64/* -R && \
      chown www-data:www-data /usr/bin/chrome-headless-shell-linux64 && \
      chmod 775 /usr/bin/chrome-headless-shell-linux64/* -R && \
      chmod 775 /usr/bin/chrome-headless-shell-linux64 \
    )

RUN rm -rf /tmp/php-driver
RUN mkdir -p /apache-conf
VOLUME /apache-conf

RUN mkdir -p /etc/apache2/ssl
VOLUME /etc/apache2/ssl

RUN mkdir -p $LDAP_CONF_DIR
RUN echo '#' > $LDAP_CONF_FILE
RUN echo '# LDAP Defaults'  >> $LDAP_CONF_FILE
RUN echo '#' >> $LDAP_CONF_FILE
RUN echo ''  >> $LDAP_CONF_FILE
RUN echo '# See ldap.conf(5) for details' >> $LDAP_CONF_FILE
RUN echo '# This file should be world readable but not world writable.' >> $LDAP_CONF_FILE
RUN echo ' ' >> $LDAP_CONF_FILE
RUN echo '#BASE   dc=example,dc=com' >> $LDAP_CONF_FILE
RUN echo  '#URI    ldap://ldap.example.com ldap://ldap-master.example.com:666' >> $LDAP_CONF_FILE
RUN echo ' ' >> $LDAP_CONF_FILE
RUN echo '#SIZELIMIT      12' >> $LDAP_CONF_FILE
RUN echo '#TIMELIMIT      15' >> $LDAP_CONF_FILE
RUN echo '#DEREF          never' >> $LDAP_CONF_FILE
RUN echo ' ' >> $LDAP_CONF_FILE
RUN echo '# TLS certificates (needed for GnuTLS)' >> $LDAP_CONF_FILE
RUN echo 'TLS_CACERT      /etc/ssl/certs/ca-certificates.crt' >> $LDAP_CONF_FILE

COPY apache_testrail.conf /apache-conf/000-default.conf
COPY ssl_apache_testrail.conf /apache-conf/ssl_apache_testrail.conf
COPY .htaccess /apache-conf/.htaccess

COPY custom-entrypoint.sh /custom-entrypoint.sh
ENTRYPOINT ["/custom-entrypoint.sh"]
CMD ["apache2-foreground"]

WORKDIR /var/www/testrail
EXPOSE 80
