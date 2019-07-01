#!/bin/bash
#set -e

function createOptDirectory {
    if [ ! -d $1 ]
    then
        echo "Creating " $1
        mkdir -p $1
    fi

    chown -R www-data:www-data $1
}


createOptDirectory $TR_DEFAULT_LOG_DIR
createOptDirectory $TR_DEFAULT_AUDIT_DIR
createOptDirectory $TR_DEFAULT_REPORT_DIR
createOptDirectory $TR_DEFAULT_ATTACHMENT_DIR


chown -R www-data:www-data /var/www/testrail/config


echo "##############"
echo "Waiting for background task file"
while [ ! -f /var/www/testrail/task.php ]
do
  sleep 2
done

echo "Starting background task"
while /bin/true; do
    php /var/www/testrail/task.php || true
    sleep $TR_DEFAULT_TASK_EXECUTION
done &
echo "##############"

docker-php-entrypoint "$@"