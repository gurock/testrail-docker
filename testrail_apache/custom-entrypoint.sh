#!/bin/bash
#set -e

echo "##############"
echo "Waiting for background task file"
while [ ! -f /var/www/testrail/task.php ]
do
  sleep 2
done

echo "Starting background task"
while /bin/true; do
    php /var/www/testrail/task.php || true
    sleep 60
done &
echo "##############"

docker-php-entrypoint "$@"a