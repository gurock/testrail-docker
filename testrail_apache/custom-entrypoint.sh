#!/bin/bash
#set -e

rm -f /etc/apache2/sites-enabled/ssl_apache_testrail.conf
cp /apache-conf/000-default.conf /etc/apache2/sites-enabled/000-default.conf

if [ ! -z "$SSL" ]
then
    echo
    echo "####################################################"
    echo "  Applying SSL configuration -- please ensure that certificate and key files exist"
    echo "####################################################"
    echo

    cp -f /ssl_apache_testrail.conf /etc/apache2/sites-enabled/ssl_apache_testrail.conf
fi

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

docker-php-entrypoint "$@"