#!/bin/bash
set -e

if [ -n "$DB_URL" ]; then
    echo
    echo "####################################################"
    echo "  Downloading existing TestRail DB dump from URL:"
    echo "  $DB_URL"
    echo "####################################################"
    echo

    curl -L --insecure "$DB_URL" \
        -o /docker-entrypoint-initdb.d/db.sql

    echo "DB downloaded"
    echo "####################################################"
fi

exec docker-entrypoint.sh mysqld "$@"