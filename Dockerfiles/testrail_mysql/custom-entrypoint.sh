#!/bin/bash
set -e

if [ ! -z "$DB_URL" ] && [ "${#DB_URL}" != 0 ]
then
    echo
    echo "####################################################"
    echo "  Downloading existing TestRail DB dump from URL: " $DB_URL
    echo "####################################################"
    echo

    wget --no-check-certificate -O /docker-entrypoint-initdb.d/db.sql $DB_URL

    echo "DB downloaded"
    echo "####################################################"
fi

exec docker-entrypoint.sh mysqld"$@"

