#!/bin/bash
set -e

rm -f /etc/nginx/conf.d/ssl_testrail.conf
cp -f /nginx-conf/default.conf /etc/nginx/conf.d/default.conf

if [ -n "$SSL" ]
then
    echo
    echo "####################################################"
    echo "  Applying SSL configuration -- please ensure that certificate and key files exist"
    echo "####################################################"
    echo

    cp -f /nginx-conf/ssl_testrail.conf /etc/nginx/conf.d/ssl_testrail.conf
fi

echo
echo "####################################################"
echo "  Nginx will be started now ;-)"
echo "####################################################"
echo

nginx -g 'daemon off;'