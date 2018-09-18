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

RUN \
  wget --no-check-certificate -O /tmp/testrail.zip ${ARG_URL} && \
  mkdir -p /var/www/testrail && \
  unzip /tmp/testrail.zip -d /tmp && \
  mv /tmp/testrail/* /var/www/html/ && \
  mkdir -p /var/www/html/logs && chown www-data:www-data /var/www/html/logs && \
  mkdir /etc/cron.d && echo '* * * * * www-data /usr/bin/php /var/www/html/task.php' >> /etc/cron.d/testrail && chmod +x /etc/cron.d/testrail

VOLUME /opt/testrail/attachments
VOLUME /opt/testrail/reports

EXPOSE 80
