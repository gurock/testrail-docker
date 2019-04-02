ARG ARG_PHP_VERSION=7.0
FROM php:${ARG_PHP_VERSION}-apache

ARG ARG_IONCUBE_VERSION=10.2.4
ARG ARG_PHP_VERSION=7.0
ARG ARG_URL=https://secure.gurock.com/downloads/testrail/testrail-latest-ion70.zip

LABEL vendor="TestRail" \
      maintainer="Christian Breitwieser" \
      email="cbreitwieser@ranorex.com" \
      type="TestRail php-fpm apache image including ionCube loader." \
      description="This is an image which runs apache php-fpm with ionCube for testrail."

RUN \
    apt-get update && \
    apt-get install -y zip && \
    apt-get install -y wget && \
    apt-get install -y unzip && \
    apt-get install -y zlib1g-dev && \
    apt-get install -y libcurl4-gnutls-dev && \
    apt-get clean && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install curl && \
    docker-php-ext-install zip && \
    rm -rf /var/lib/apt/lists/*

RUN \
  wget  -O /tmp/ioncube.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64_${ARG_IONCUBE_VERSION}.tar.gz && \
  tar -xzf /tmp/ioncube.tar.gz -C /tmp && \
  mv /tmp/ioncube /opt/ioncube && \
  echo zend_extension=/opt/ioncube/ioncube_loader_lin_${ARG_PHP_VERSION}.so >> /usr/local/etc/php/php.ini && \
  rm -f /tmp/ioncube.tar.gz

COPY php.ini /usr/local/etc/php/conf.d/php.ini

RUN \
  wget --no-check-certificate -O /tmp/testrail.zip ${ARG_URL} && \
  mkdir -p /var/www/testrail && \
  mkdir -p /opt/testrail/attachments /opt/testrail/reports && \
  unzip /tmp/testrail.zip -d /tmp && \
  rm /tmp/testrail.zip && \
  mv /tmp/testrail /var/www/ && \
  chown -R www-data:www-data /var/www/testrail && \
  chown -R www-data:www-data /opt/testrail && \
  mkdir -p /var/www/testrail/logs  && chown www-data:www-data /var/www/testrail/logs && \
  mkdir -p /var/www/testrail/audit && chown www-data:www-data /var/www/testrail/audit

COPY apache_testrail.conf /etc/apache2/sites-enabled/000-default.conf

VOLUME /opt/testrail/attachments
VOLUME /opt/testrail/reports

COPY custom-entrypoint.sh /custom-entrypoint.sh
ENTRYPOINT ["/custom-entrypoint.sh"]
CMD ["apache2-foreground"]

WORKDIR /var/www/testrail
EXPOSE 80
