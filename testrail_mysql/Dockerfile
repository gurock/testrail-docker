ARG ARG_MYSQL_VERSION=latest
FROM mysql:${ARG_MYSQL_VERSION}

LABEL vendor="TestRail" \
      maintainer="Christian Breitwieser" \
      email="cbreitwieser@ranorex.com" \
      type="TestRail mariadb image" \
      description="This is an image which runs mysql and accepts a link to a db-dump for initialization."
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY config.php /config.php
COPY custom-entrypoint.sh /custom-entrypoint.sh

VOLUME /var/lib/mysql

ENTRYPOINT ["/custom-entrypoint.sh"]
