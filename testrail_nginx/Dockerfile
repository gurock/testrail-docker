ARG ARG_NGINX_VERSION=latest
FROM nginx:${ARG_NGINX_VERSION}

ARG ARG_URL=https://secure.gurock.com/downloads/testrail/testrail-latest-ion70.zip

LABEL vendor="TestRail" \
      maintainer="Christian Breitwieser" \
      email="cbreitwieser@ranorex.com" \
      type="TestRail nginx webserver" \
      description="This is a docker base image which contains a fully configured TestRail webserver."

RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends curl zip unzip wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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

COPY http_testrail.conf /etc/nginx/conf.d/default.conf

VOLUME /opt/testrail/attachments
VOLUME /opt/testrail/reports

