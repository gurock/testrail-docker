ARG ARG_MARIADB_VERSION=latest
FROM mariadb:${ARG_MARIADB_VERSION}

LABEL vendor="TestRail" \
      maintainer="Christian Breitwieser" \
      email="cbreitwieser@ranorex.com" \
      type="TestRail mariadb image" \
      description="This is an image which runs mariadb and accepts a link to a db-dump for initialization."
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends wget iputils-ping && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY custom-entrypoint.sh /custom-entrypoint.sh

VOLUME /var/lib/mysql

ENTRYPOINT ["/custom-entrypoint.sh"]
