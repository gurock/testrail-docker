ARG ARG_NGINX_VERSION=latest
FROM nginx:${ARG_NGINX_VERSION}

LABEL vendor="TestRail" \
      maintainer="Christian Breitwieser" \
      email="cbreitwieser@ranorex.com" \
      type="TestRail nginx webserver" \
      description="This is a docker base image which contains a fully configured TestRail webserver."

RUN mkdir -p /etc/nginx/ssl
VOLUME /etc/nginx/ssl

RUN mkdir -p /nginx-conf
VOLUME /nginx-conf

COPY nginx_testrail.conf /nginx-conf/default.conf
COPY ssl_nginx_testrail.conf /nginx-conf/ssl_testrail.conf

COPY custom-entrypoint.sh /custom-entrypoint.sh
RUN chown www-data:www-data /custom-entrypoint.sh

ENTRYPOINT ["/custom-entrypoint.sh"]

WORKDIR /var/www/testrail
EXPOSE 80