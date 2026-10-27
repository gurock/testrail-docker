ARG ARG_PHP_VERSION=8.1
FROM php:${ARG_PHP_VERSION}-apache-bookworm

ARG ARG_PHP_VERSION=8.1
ARG ARG_IONCUBE_VERSION=12.0.5
ARG ARG_URL=https://secure.testrail.com/downloads/testrail/testrail-9.8.1.1506-ion81.zip

# Custom patched PHP source (CVE-2026-109618 / CVE-2026-109619 backport on the
# PHP-8.1 line). Pinned to a specific commit for reproducible builds. Still
# version 8.1.34 on the 8.1 ABI, so the ionCube 8.1 loader stays compatible.
ARG ARG_PHP_SRC_REPO=https://github.com/php/php-src.git
ARG ARG_PHP_SRC_REF=1d7dec178a094e6e75b229ce22754045f8c6070a

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
    apt-get install -y --no-install-recommends libzip-dev zlib1g-dev libcurl4-gnutls-dev libldap2-dev zlib1g-dev libxml2-dev libfontconfig1 libpng-dev libjpeg-dev libmagickwand-dev && \
    apt-get install -y --only-upgrade apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Rebuild the PHP binaries from the custom patched source, in place over the
# official image, reusing its EXACT configure options (php-config
# --configure-options) so that every docker-php-ext-* helper, the apache SAPI
# and the ionCube loader below keep working unchanged.
RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    DEBIAN_FRONTEND=noninteractive apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates git autoconf gcc g++ make pkg-config bison re2c \
        apache2-dev \
        libxml2-dev libssl-dev libreadline-dev \
        libsodium-dev libsqlite3-dev libonig-dev zlib1g-dev libargon2-dev; \
    phpConfigureOpts="$(php-config --configure-options)"; \
    mkdir -p /usr/src/php-custom; cd /usr/src/php-custom; \
    git init -q; \
    git remote add origin "$ARG_PHP_SRC_REPO"; \
    git fetch -q --depth 1 origin "$ARG_PHP_SRC_REF"; \
    git checkout -q FETCH_HEAD; \
    ./buildconf --force; \
    eval ./configure $phpConfigureOpts; \
    make -j"$(nproc)"; \
    make install; \
    make clean; \
    # Replace the image's bundled source tarball so later docker-php-ext-install
    # steps compile bundled extensions from the patched source too.
    rm -f /usr/src/php.tar.xz /usr/src/php.tar.xz.asc; \
    tar -cJf /usr/src/php.tar.xz -C /usr/src --transform 's,^php-custom,php,' php-custom; \
    cd /; rm -rf /usr/src/php-custom; \
    php -v; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark > /dev/null; \
    # Mark as manual every package providing a shared lib that the freshly
    # compiled PHP binaries/extensions actually link, so the later cleanup
    # steps don't autoremove runtime deps (e.g. libcurl-gnutls) out from
    # under the self-built (dpkg-invisible) PHP binary.
    find /usr/local -type f -executable -exec ldd '{}' ';' 2>/dev/null \
        | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) next; gsub("^/(usr/)?", "", so); printf "*/%s\n", so }' \
        | sort -u \
        | xargs -r dpkg-query --search 2>/dev/null \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r apt-mark manual > /dev/null; \
    # The compiled PHP core links the gnutls flavour of libcurl (from the
    # libcurl4-gnutls-dev installed earlier). A later build stage removes that
    # -dev package, which would orphan the libcurl-gnutls runtime lib and break
    # the PHP binary. Pin it manual so it survives every autoremove downstream.
    apt-mark manual libcurl3-gnutls > /dev/null; \
    apt-get autoremove -y; \
    apt-get clean; \
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
RUN pecl install --nodeps imagick
RUN docker-php-ext-enable imagick

RUN ( cd /tmp && \
      curl https://dist.libuv.org/dist/v1.35.0/libuv-v1.35.0.tar.gz -o libuv.tgz  && tar xzf libuv.tgz && \
      cd libuv-v1.35.0 && \
      sh autogen.sh && \
      ./configure && \
      make install \
    )
RUN rm -rf /tmp/libuv-v1.35.0 /tmp/libuv.tgz

# PHP Cassandra driver (cassandra.so). Required by older TestRail releases
# (8.0.1.1029 .. 9.4.1.1016); without it those versions 500 on start. Built
# here (after the PHP 8.1.34 recompile) so phpize compiles against the patched
# headers. Enabled via "extension=cassandra.so" in php.ini.
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
RUN rm -rf /tmp/cassandra-php-driver

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

RUN apt-get -y remove build-essential cmake git libkrb5-dev libtool libssl-dev libgmp-dev libpcre3-dev linux-libc-dev
RUN apt-get -y remove gcc make autoconf libc-dev pkg-config
RUN apt-get -y remove libmcrypt-dev
RUN apt-get -y remove libzip-dev zlib1g-dev libcurl4-gnutls-dev libldap2-dev zlib1g-dev libxml2-dev libpng-dev libjpeg-dev
RUN apt-get install --no-install-recommends -yq libzip4 libgd-tools
RUN apt-mark manual libmagickcore-6-arch-config libmagickcore-6-headers libmagickcore-6.q16-6-extra libmagickwand-6-headers imagemagick-6-common libmagickwand-6.q16-6
RUN apt autoremove -yq && apt autoclean -qy

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

RUN echo '<FilesMatch "\.(sql|ini)$">\n    Require all denied\n</FilesMatch>' > /var/www/testrail/.htaccess
RUN chmod 644 /var/www/testrail/.htaccess

COPY custom-entrypoint.sh /custom-entrypoint.sh
ENTRYPOINT ["/custom-entrypoint.sh"]
CMD ["apache2-foreground"]

WORKDIR /var/www/testrail
EXPOSE 80
