ARG ARG_MYSQL_VERSION=8.4
FROM mysql:${ARG_MYSQL_VERSION}

LABEL vendor="TestRail" \
      maintainer="Christian Breitwieser" \
      email="cbreitwieser@ranorex.com" \
      type="TestRail mysql image" \
      description="MySQL image for TestRail with custom entrypoint."

COPY custom-entrypoint.sh /custom-entrypoint.sh
RUN chmod +x /custom-entrypoint.sh

VOLUME /var/lib/mysql

ENTRYPOINT ["/custom-entrypoint.sh"]
