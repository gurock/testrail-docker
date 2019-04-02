ARG ARG_NGINX_VERSION=latest
FROM nginx:${ARG_NGINX_VERSION}

LABEL vendor="TestRail" \
      maintainer="Christian Breitwieser" \
      email="cbreitwieser@ranorex.com" \
      type="TestRail nginx webserver" \
      description="This is a docker base image which contains a fully configured TestRail webserver."

RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends curl zip unzip wget iputils-ping && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY http_testrail.conf /etc/nginx/conf.d/default.conf

VOLUME /opt/testrail/attachments
VOLUME /opt/testrail/reports

